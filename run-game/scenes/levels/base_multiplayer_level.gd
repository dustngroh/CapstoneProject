extends Node2D

@export var player_scene: PackedScene
@export var multiplayer_player_scene: PackedScene

var base_level_path = "res://scenes/levels/multiplayer_levels/multiplayer_level_"
@export var current_level_number = 1
@export var total_levels = 1
@export var countdown_seconds = 3

var player: CharacterBody2D
var elapsed_time: float = 0.0  # Time starts at 0
@export var level_end_time: float = 60.0 # Time to force end a level
var timer_running: bool = false # Paused until countdown ends
var position_update_timer: float = 0.0  # Timer to control how often we send position updates
var position_update_interval: float = 0.05

var players: Dictionary = {}
var game_finished = false
var player_finished = false

@onready var game: Node = get_tree().root.get_node("Game")
@onready var level_ui: Control = UIManager.get_node("LevelUI")
@onready var level_timer: Timer = $Timer
@onready var time_label: Label = UIManager.get_node("LevelUI/TimeLabel")
@onready var win_zone: Area2D = $WinZone
@onready var leaderboard: CanvasLayer = UIManager.get_node("LevelUI/Leaderboard")
@onready var level_options: VBoxContainer = leaderboard.get_node("VBoxContainer")
@onready var leaderboard_label: Label = leaderboard.get_node("Label")
@onready var countdown_label: Label = UIManager.get_node("LevelUI/CountdownLabel")
@onready var level_label: Label = UIManager.get_node("LevelUI/LevelLabel")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var countdown_player: AudioStreamPlayer = UIManager.get_node("LevelUI/CountdownAudio")
@onready var start_player: AudioStreamPlayer = UIManager.get_node("LevelUI/StartAudio")
#@onready var scoreboard_label: Label = UIManager.get_node("LevelUI/ScoreboardLabel")
@onready var scoreboard_label: Label = leaderboard.get_node("LeaderboardBox")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_player()
	
	WebSocketManager.all_players_ready.connect(start_countdown)
	WebSocketManager.level_complete.connect(_on_level_complete)
	WebSocketManager.start_level.connect(start_level)
	WebSocketManager.player_position_updated.connect(update_position)
	WebSocketManager.new_host.connect(_on_new_host)
	
	UIManager.show_level_ui()
	scoreboard_label.visible = false
	level_options.visible = false
	
	# Set up Timer
	level_timer.wait_time = 1.0
	level_timer.one_shot = false
	
	# Make sure timer displays 0 at start
	update_timer_display()

	# Show the level label and countdown timer
	level_label.text = "Level " + str(current_level_number)
	level_label.show()
	
	leaderboard.visible = false
	leaderboard.get_node("VBoxContainer/NextLevelButton").pressed.connect(_on_next_button_pressed)
	leaderboard.get_node("VBoxContainer/MainMenuButton").pressed.connect(_on_main_button_pressed)
	leaderboard.get_node("VBoxContainer/ResetButton").pressed.connect(_on_reset_button_pressed)

	
	WebSocketManager.mark_ready()
	send_player_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer_running:
		elapsed_time += delta
		update_timer_display()
		
		if elapsed_time > level_end_time:
			if !player_finished:
				_on_win_zone_win()
		
		position_update_timer += delta
		if position_update_timer >= position_update_interval:
			send_player_position()
			position_update_timer = 0.0

func spawn_player():
	if player_scene:
		player = player_scene.instantiate()  # Create an instance of Player
		add_child(player)  # Add to the scene
		player.global_position = spawn_point.global_position  # Move to SpawnPoint
		player.set_physics_process(false)  # Disable movement until countdown ends

func _on_bottom_world_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Ensure it's the player
		body.position = spawn_point.position  # Respawn at the spawn point

func update_timer_display():
	time_label.text = "Time: %.2f" % elapsed_time  # Show time in seconds with 2 decimals
	

func _on_win_zone_win():
	player_finished = true
	stop_timer()
	leaderboard.visible = true
	scoreboard_label.text = "Waiting on all players to finish..."
	scoreboard_label.visible = true
	WebSocketManager.send_player_finish(elapsed_time)

func start_countdown():
	countdown_label.show()
	for i in range(countdown_seconds, 0, -1):  # Countdown from countdown_seconds to 1
		countdown_label.text = str(i)
		countdown_player.play()
		level_timer.start(1.0)
		await level_timer.timeout
	
	countdown_label.text = "Go!"
	start_player.play()
	await get_tree().create_timer(0.5).timeout  # Show "Go!" briefly
	countdown_label.hide()
	level_label.hide() 
	
	# Start the timer
	timer_running = true
	level_timer.start()
	player.set_physics_process(true)  # Enable player movement

func stop_timer():
	timer_running = false
	level_timer.stop()
	leaderboard_label.text = "Final time: %.2f seconds" % elapsed_time
	print("Final time: %.2f seconds" % elapsed_time)


func _on_level_complete(scoreboard: Array):
	game_finished = true
	print("Level Complete! Final Results:", scoreboard)
	level_options.visible = WebSocketManager.is_host
	display_scoreboard(scoreboard)

func display_scoreboard(scoreboard: Array):
	var scoreboard_text = "Final Scoreboard:\n"
	for result in scoreboard:
		scoreboard_text += "%d. %s - %.2f seconds\n" % [result["rank"], result["name"], result["time"]]

	# Update the label text
	scoreboard_label.text = scoreboard_text
	
	scoreboard_label.visible = true


func _on_next_button_pressed():
	WebSocketManager.start_game((current_level_number % total_levels) + 1)
	
func _on_reset_button_pressed():
	WebSocketManager.start_game(current_level_number)
	
func _on_main_button_pressed():
	WebSocketManager.disconnect_from_server()
	MusicManager.play_music("res://assets/audio/music/Lite Saturation - Calm.mp3")
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
	
func start_level(level_number: int) -> void:
	var current_level_path = base_level_path + str(level_number) + ".tscn"
	
	if game:
		game.load_level(current_level_path)

func send_player_position():
	if player:
		var position = player.position
		var data = {
			"type": "player_position",
			"id": player.get_instance_id(),  # Unique identifier for the player
			"name": WebSocketManager.player_name,
			"x": position.x,
			"y": position.y
		}
		WebSocketManager.send_message(data)

func update_position(player_id, player_name, player_x, player_y):
	# Check if the player exists in the dictionary
	if not players.has(player_id):
		# If not, spawn a new player and add to the dictionary
		var new_player = multiplayer_player_scene.instantiate()
		add_child(new_player)  # Add to the scene
		new_player.global_position = Vector2(player_x, player_y)  # Set position
		new_player.update_name(player_name)  # Set name
		players[player_id] = new_player  # Store the new player in the dictionary
	else:
		# If the player exists, update their position
		var existing_player = players[player_id]
		existing_player.global_position = Vector2(player_x, player_y)

func _on_new_host():
	if game_finished:
		level_options.visible = true
