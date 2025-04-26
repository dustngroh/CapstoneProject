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
@onready var level_ui: Control = UIManager.get_node("LevelUI")
@onready var level_timer: Timer = $Timer
@onready var time_label: Label = UIManager.get_node("LevelUI/TimeLabel")
@onready var win_zone: Area2D = $WinZone
@onready var leaderboard: CanvasLayer = UIManager.get_node("LevelUI/Leaderboard")
@onready var level_options: VBoxContainer = leaderboard.get_node("VBoxContainer")
@onready var leaderboard_label: Label = leaderboard.get_node("Label")
@onready var leaderboard_box = leaderboard.get_node("LeaderboardBox")
@onready var login_button = leaderboard.get_node("VBoxContainer/LoginButton")
@onready var countdown_label: Label = UIManager.get_node("LevelUI/CountdownLabel")
@onready var level_label: Label = UIManager.get_node("LevelUI/LevelLabel")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var countdown_player: AudioStreamPlayer = UIManager.get_node("LevelUI/CountdownAudio")
@onready var start_player: AudioStreamPlayer = UIManager.get_node("LevelUI/StartAudio")



func _ready():
	resize_background()
	get_viewport().size_changed.connect(resize_background)
	
	spawn_player()
	
	# Ensure level UI is visible
	UIManager.show_level_ui()
	UIManager.get_node("FadeLayer").fade_out(1.0) #TESTING PURPOSES: REMOVE THIS LATER
	
	# Set up Timer
	level_timer.wait_time = 1.0
	level_timer.one_shot = false
	
	# Make sure timer displays 0 at start
	update_timer_display()

	# Show the level label and countdown timer
	level_label.text = "Level " + str(current_level_number)
	level_label.show()
	countdown_label.show()
	start_countdown()
	
	# Hide leaderboard initially
	leaderboard.visible = false
	
	# Connect leaderboard buttons
	leaderboard.get_node("VBoxContainer/NextLevelButton").pressed.connect(_on_next_button_pressed)
	leaderboard.get_node("VBoxContainer/ResetButton").pressed.connect(_on_reset_button_pressed)
	leaderboard.get_node("VBoxContainer/MainMenuButton").pressed.connect(_on_main_button_pressed)
	leaderboard.get_node("VBoxContainer/ReplayButton").pressed.connect(play_replay)
	login_button.pressed.connect(_on_login_button_pressed)
	login_button.visible = !HTTPRequestManager.is_logged_in()
	HTTPRequestManager.leaderboard_received.connect(_on_leaderboard_received)
	
	# Check for admin controls
	if Settings.admin_controls_enabled:
		if admin_controls_instance == null:
			admin_controls_instance = admin_controls_scene.instantiate() # Only instantiated if enabled
			# Add the admin controls to the UI
			level_ui.add_child(admin_controls_instance)
			
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


func resize_background():
	#var background_sprite = $Parallax2D/Sprite2D
	var background_sprite = $LevelBackground/ParallaxLayer/Sprite2D
	var screen_size = get_viewport().get_visible_rect().size
	var texture_size = background_sprite.texture.get_size()

	# First: scale by Y to maintain aspect ratio
	var scale_y = screen_size.y / texture_size.y
	var scaled_width = texture_size.x * scale_y

	# Check if X does not fill screen
	if scaled_width < screen_size.x:
		# Scale by X instead
		var scale_x = screen_size.x / texture_size.x
		background_sprite.scale = Vector2(scale_x, scale_x)
	else:
		background_sprite.scale = Vector2(scale_y, scale_y)


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
	player.end_recording()
	# Submit time to backend
	if HTTPRequestManager.is_logged_in():
		if not HTTPRequestManager.is_connected("score_submission_result", _on_score_submitted):
			HTTPRequestManager.score_submission_result.connect(_on_score_submitted)
			HTTPRequestManager.world_record_achieved.connect(_on_world_record)
			HTTPRequestManager.personal_record_achieved.connect(_on_personal_record)
			
		leaderboard_box.text = "Submitting Time...\nThis may take a minute."
		HTTPRequestManager.submit_time(current_level_number, elapsed_time)
	else:
		leaderboard_label.text += "\nLogin to submit your time!"
		HTTPRequestManager.login_success.connect(_on_login_success)
		HTTPRequestManager.register_success.connect(_on_account_creation)
		HTTPRequestManager.login_failed.connect(_on_failed_login)
		HTTPRequestManager.register_failed.connect(_on_failed_register)
		print("Not logged in — time not submitted.")
		show_leaderboard()  # Fetch leaderboard immediately

func _on_score_submitted(message: String):
	print("Score submission complete: ", message)
	show_leaderboard()
	HTTPRequestManager.score_submission_result.disconnect(_on_score_submitted)

func _on_world_record(message: String):
	print("Score submission complete: ", message)
	leaderboard_label.text += "\nNEW WORLD RECORD!\nABSOLUTE LEGEND"
	show_leaderboard()
	HTTPRequestManager.world_record_achieved.disconnect(_on_world_record)

func _on_personal_record(message: String):
	print("Score submission complete: ", message)
	leaderboard_label.text += "\nNew Personal Best!"
	show_leaderboard()
	HTTPRequestManager.personal_record_achieved.disconnect(_on_personal_record)

func start_countdown():
	for i in range(countdown_seconds, 0, -1):  # Countdown from countdown_seconds to 1
		countdown_label.text = str(i)
		countdown_player.play()
		#await get_tree().create_timer(1.0).timeout  # Wait 1 second per number
		level_timer.start(1.0)
		await level_timer.timeout
	
	countdown_label.text = "Go!"
	start_player.play()
	#await get_tree().create_timer(0.5).timeout  # Show "Go!" briefly
	level_timer.start(0.5)
	await level_timer.timeout
	countdown_label.hide()
	level_label.hide() 
	
	# Start the timer
	timer_running = true
	level_timer.start()
	player.set_physics_process(true)  # Enable player movement
	player.recording = true   # Start recording player positions

func stop_timer():
	timer_running = false
	level_timer.stop()
	leaderboard_label.text = "Final time: %.2f seconds" % elapsed_time
	print("Final time: %.2f seconds" % elapsed_time)

func show_leaderboard():
	leaderboard.visible = true
	level_options.visible = true
	leaderboard_box.visible = true
	
	leaderboard_box.text = "Fetching Leaderboard...\nThis may take a minute."
	
	# Fetch leaderboard and display results
	HTTPRequestManager.fetch_leaderboard(current_level_number)
	
	#await get_tree().create_timer(1.0).timeout  # Wait for API response

func _on_leaderboard_received(level: int, scores: Array):
	if level != current_level_number:
		return  # Ensure it's for the current level

	leaderboard_box.text = "Top Times:\n"

	for i in range(scores.size()):
		var score = scores[i]
		var time_in_seconds = float(score["completion_time"]) / 100.0
		leaderboard_box.text += "%d. %s - %.2f seconds\n" % [i + 1, score["username"], time_in_seconds]


func _on_bottom_world_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Ensure it's the player
		body.position = spawn_point.position  # Respawn at the spawn point

func _on_next_button_pressed():
	current_level_number = (current_level_number % total_levels) + 1  # Cycle from 1 to 4
	var next_level_path = base_level_path + str(current_level_number) + ".tscn"
	
	if game:
		game.load_level(next_level_path)

func _on_reset_button_pressed():
	var curr_level_path = base_level_path + str(current_level_number) + ".tscn"
	
	if game:
		game.load_level(curr_level_path)

func _on_previous_button_pressed():
	current_level_number = (current_level_number - 2 + total_levels) % total_levels + 1  # Cycle backwards
	var previous_level_path = base_level_path + str(current_level_number) + ".tscn"
	
	if game:
		game.load_level(previous_level_path)

func _on_main_button_pressed():
	#MusicManager.play_music("res://assets/audio/music/Lite Saturation - Calm.mp3")
	MusicManager.play_random_menu_music()
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")

func _on_login_button_pressed():
	UIManager.show_login()

func play_replay():
	if not player or player.position_history.is_empty():
		return

	player.zoom_out()   # Zoom out camera
	player.set_physics_process(false)  # Disable player movement during replay
	player.modulate = Color(1, 1, 1, 0.5)  # Make the replay character semi-transparent
	leaderboard.visible = false   # Hide leaderboard during replay

	for pos in player.position_history:
		player.global_position = pos
		await get_tree().create_timer(player.record_interval).timeout  # Wait between frames

	player.zoom_in()   # Zoom camera back in
	player.set_physics_process(true)  # Enable movement again after replay
	player.modulate = Color(1, 1, 1, 1)  # Undo transparency
	leaderboard.visible = true   # Show leaderboard again


# Method called if user logs in after comlpeting the level
func _on_login_success(user) -> void:
	UIManager.hide_login()
	login_button.visible = false
	# Call win method again to submit score
	_on_win_zone_win()
	print("Logged in!")

func _on_account_creation(user) -> void:
	UIManager._on_account_created(user)

func _on_failed_login(error) -> void:
	UIManager._on_failed_login(error)
	
func _on_failed_register(error) -> void:
	UIManager._on_failed_register(error)
