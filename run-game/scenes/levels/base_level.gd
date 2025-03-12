extends Node2D

@export var player_scene: PackedScene
@export var admin_controls_scene: PackedScene
@export var touch_controls_scene: PackedScene
@export var current_level_number = 1
@export var countdown_seconds = 3

var base_level_path = "res://scenes/levels/main_levels/level_"
var total_levels = 4

var admin_controls_instance: Control = null
var touch_controls_instance: Control = null


var player: CharacterBody2D
var elapsed_time: float = 0.0  # Time starts at 0
var timer_running: bool = false # Paused until countdown ends

@onready var game: Node = get_tree().root.get_node("Game")
@onready var level_timer: Timer = $Timer
@onready var time_label: Label = $UI/TimeLabel
@onready var win_zone: Area2D = $WinZone
@onready var leaderboard: CanvasLayer = $UI/Leaderboard
@onready var countdown_label: Label = $UI/CountdownLabel
@onready var level_label: Label = $UI/LevelLabel
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var countdown_player: AudioStreamPlayer = $UI/CountdownAudio
@onready var start_player: AudioStreamPlayer = $UI/StartAudio


func _ready():
	# Check for touch controls, must be added before spawn_player()
	if Settings.touch_controls_enabled:
		
		# Remove any existing controls first
		var existing_touch_controls = get_tree().get_nodes_in_group("TouchControls") 
		for control in existing_touch_controls:
			control.free()
		
		# Add new controls
		if touch_controls_instance == null:
			touch_controls_instance = touch_controls_scene.instantiate() # Only instantiated if enabled
			$UI.add_child(touch_controls_instance)  # Add the touch controls to the UI
	
	spawn_player()
	
	# Set up Timer
	level_timer.wait_time = 1.0
	level_timer.one_shot = false

	level_label.text = "Level " + str(current_level_number)
	level_label.show()
	countdown_label.show()
	start_countdown()

	# Hide leaderboard initially
	leaderboard.visible = false
	
	# Connect leaderboard buttons
	leaderboard.get_node("NextLevelButton").pressed.connect(_on_next_button_pressed)
	leaderboard.get_node("MainMenuButton").pressed.connect(_on_main_button_pressed)
	
	# Check for admin controls
	if Settings.admin_controls_enabled:
		if admin_controls_instance == null:
			admin_controls_instance = admin_controls_scene.instantiate() # Only instantiated if enabled
			$UI.add_child(admin_controls_instance)  # Add the admin controls to the UI
			
			# Connect buttons
			var next_level_button = admin_controls_instance.get_node("VBoxContainer/NextLevelButton")
			var previous_level_button = admin_controls_instance.get_node("VBoxContainer/PreviousLevelButton")
			var main_menu_button = admin_controls_instance.get_node("VBoxContainer/MainMenuButton")
			next_level_button.pressed.connect(_on_next_button_pressed)
			previous_level_button.pressed.connect(_on_previous_button_pressed)
			main_menu_button.pressed.connect(_on_main_button_pressed)


func _process(delta):
	if timer_running:
		elapsed_time += delta
		update_timer_display()

func update_timer_display():
	time_label.text = "Time: %.2f" % elapsed_time  # Show time in seconds with 2 decimals

func spawn_player():
	if player_scene:
		player = player_scene.instantiate()  # Create an instance of Player
		add_child(player)  # Add to the scene
		player.global_position = spawn_point.global_position  # Move to SpawnPoint
		player.set_physics_process(false)  # Disable movement until countdown ends

func _on_win_zone_win():
	stop_timer()
	show_leaderboard()

func start_countdown():
	for i in range(countdown_seconds, 0, -1):  # Countdown from countdown_seconds to 1
		countdown_label.text = str(i)
		countdown_player.play()
		await get_tree().create_timer(1.0).timeout  # Wait 1 second per number
	
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
	print("Final time: %.2f seconds" % elapsed_time)

func show_leaderboard():
	leaderboard.visible = true
	
	# Fetch leaderboard and display results
	# TODO: Implement leaderboard fetching from backend
	#GameManager.fetch_leaderboard(leve_name)  # Fetch scores for this level
	
	await get_tree().create_timer(1.0).timeout  # Wait for API response
	
	
	$UI/Leaderboard/Label.text = "Final time: %.2f seconds" % elapsed_time # Display their time


func _on_bottom_world_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Ensure it's the player
		body.position = spawn_point.position  # Respawn at the spawn point

func _on_next_button_pressed():
	current_level_number = (current_level_number % total_levels) + 1  # Cycle from 1 to 4
	var next_level_path = base_level_path + str(current_level_number) + ".tscn"
	
	if game:
		game.load_level(next_level_path)

func _on_previous_button_pressed():
	current_level_number = (current_level_number - 2 + total_levels) % total_levels + 1  # Cycle backwards
	var previous_level_path = base_level_path + str(current_level_number) + ".tscn"
	
	if game:
		game.load_level(previous_level_path)

func _on_main_button_pressed():
	MusicManager.play_music("res://assets/audio/music/Lite Saturation - Calm.mp3")
	
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
