extends Node2D

@export var player_scene: PackedScene
@export var admin_controls_scene: PackedScene
@export var touch_controls_scene: PackedScene
@export var current_level_number = 1
@export var countdown_seconds = 3

var base_level_path = "res://scenes/levels/main_levels/level_"
var total_levels = 6

var admin_controls_instance: Control = null
var touch_controls_instance: Control = null
var active_tween: Tween = null

var player: CharacterBody2D
var elapsed_time: float = 0.0  # Time starts at 0
var timer_running: bool = false # Paused until countdown ends
var respawn_point: Vector2

@onready var game: Node = get_tree().root.get_node("Game")
@onready var level_ui: Control = UIManager.get_node("LevelUI")
@onready var level_timer: Timer = $Timer
#@onready var time_label: Label = UIManager.get_node("LevelUI/TimeLabel")
@onready var time_label: Label = UIManager.bottom_label
@onready var win_zone: Area2D = $WinZone
#@onready var leaderboard: CanvasLayer = UIManager.get_node("LevelUI/Leaderboard")
#@onready var level_options: VBoxContainer = leaderboard.get_node("VBoxContainer")
@onready var level_options: VBoxContainer = UIManager.controls_container
@onready var skip_button: Button = level_options.get_node("SkipButton")
#@onready var leaderboard_label: Label = leaderboard.get_node("Label")
@onready var leaderboard_label: Label = UIManager.top_label
#@onready var leaderboard_box = leaderboard.get_node("LeaderboardBox")
#@onready var login_button = leaderboard.get_node("VBoxContainer/LoginButton")
@onready var login_button = level_options.get_node("LoginButton")
@onready var countdown_label: Label = UIManager.get_node("LevelUI/CountdownLabel")
@onready var level_label: Label = UIManager.get_node("LevelUI/LevelLabel")
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var countdown_player: AudioStreamPlayer = UIManager.get_node("LevelUI/CountdownAudio")
@onready var start_player: AudioStreamPlayer = UIManager.get_node("LevelUI/StartAudio")
@onready var cutscene_camera: Camera2D = $CutsceneCamera


var is_replaying: bool = false
var replay_cancelled: bool = false
var replay_task = null
var pre_replay_position: Vector2
var ghost_requested: bool = false

@export var ghost_player_scene: PackedScene
var ghost_player: Node2D


func _ready():
	resize_background()
	get_viewport().size_changed.connect(resize_background)
	
	spawn_player()
	
	if game.should_spawn_ghost:
		print("spawning ghost")
		spawn_ghost(game.ghost_replay_data, game.ghost_total_time)
		game.should_spawn_ghost = false 
	
	# Ensure level UI is visible
	#UIManager.show_level_ui()
	UIManager.start_level_ui()
	UIManager.get_node("FadeLayer").fade_out(1.0) #TESTING PURPOSES: REMOVE THIS LATER
	UIManager.clear_top_label()
	
	
	# Set up Timer
	level_timer.wait_time = 1.0
	level_timer.one_shot = false
	
	# Make sure timer displays 0 at start
	update_timer_display()

	# Show the level label and countdown timer
	level_label.text = "Level " + str(current_level_number)
	level_label.show()
	
	
	play_cutscene()
	
	#start_countdown()
	
	# Hide leaderboard initially
	#leaderboard.visible = false
	#level_options.visible = false
	
	# Connect leaderboard buttons
	#leaderboard.get_node("VBoxContainer/NextLevelButton").pressed.connect(_on_next_button_pressed)
	level_options.get_node("NextLevelButton").pressed.connect(_on_next_button_pressed)
	#leaderboard.get_node("VBoxContainer/ResetButton").pressed.connect(_on_reset_button_pressed)
	level_options.get_node("ResetButton").pressed.connect(_on_reset_button_pressed)
	#leaderboard.get_node("VBoxContainer/MainMenuButton").pressed.connect(_on_main_button_pressed)
	level_options.get_node("MainMenuButton").pressed.connect(_on_main_button_pressed)
	#leaderboard.get_node("VBoxContainer/ReplayButton").pressed.connect(player_replay)
	level_options.get_node("ReplayButton").pressed.connect(player_replay)
	skip_button.pressed.connect(_on_skip_button_pressed)
	skip_button.visible = false
	
	login_button.pressed.connect(_on_login_button_pressed)
	#login_button.visible = !HTTPRequestManager.is_logged_in()
	HTTPRequestManager.leaderboard_received.connect(_on_leaderboard_received)
	HTTPRequestManager.replay_received.connect(_on_replay_received)


func _process(delta):
	if timer_running:
		elapsed_time += delta
		if ghost_player:
			ghost_player.update_position(elapsed_time)
		update_timer_display()

func play_cutscene() -> void:
	countdown_label.hide()
	# Make CutsceneCamera active
	cutscene_camera.make_current()
	
	# Start at spawn point
	cutscene_camera.global_position = spawn_point.global_position
	
	# Smoothly move to win zone
	var tween = create_tween()
	tween.tween_property(cutscene_camera, "global_position", win_zone.global_position, 3.0)  # Move over 3 seconds
	
	await tween.finished
	
	# After cutscene, switch back to player camera and start countdown
	cutscene_camera.queue_free()
	countdown_label.show()
	start_countdown()


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
		respawn_point = spawn_point.global_position
		player.global_position = respawn_point  # Move to SpawnPoint
		player.set_physics_process(false)  # Disable movement until countdown ends

func _on_win_zone_win():
	stop_timer()
	player.end_recording()
	#leaderboard.visible = true
	#level_options.visible = true
	UIManager.end_level_ui()
	
	
	UIManager.clear_leaderboard()
	UIManager.show_leaderboard_container()
	
	# Submit time to backend
	if HTTPRequestManager.is_logged_in():
		if not HTTPRequestManager.is_connected("score_submission_result", _on_score_submitted):
			HTTPRequestManager.score_submission_result.connect(_on_score_submitted)
			HTTPRequestManager.world_record_achieved.connect(_on_world_record)
			HTTPRequestManager.personal_record_achieved.connect(_on_personal_record)
			
		#leaderboard_status_label.text = "Submitting Time...\nThis may take a minute."
		UIManager.update_status("Submitting Time...\nThis may take a minute.")
		
		HTTPRequestManager.submit_time_with_replay(current_level_number, elapsed_time, player.position_history)
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
	#leaderboard.visible = true
	level_options.visible = true
	
	UIManager.update_status("Fetching Leaderboard...\nThis may take a minute.")
	
	# Fetch leaderboard and display results
	HTTPRequestManager.fetch_leaderboard(current_level_number)
	

func _on_leaderboard_received(level: int, scores: Array):
	if level != current_level_number:
		return  # Ensure it's for the current level

	if not UIManager.watch_replay_pressed.is_connected(_on_watch_replay_pressed):
		UIManager.watch_replay_pressed.connect(_on_watch_replay_pressed)

	if not UIManager.ghost_replay_pressed.is_connected(_on_ghost_replay_pressed):
		UIManager.ghost_replay_pressed.connect(_on_ghost_replay_pressed)


	UIManager.update_status("Top Times:")
	UIManager.populate_leaderboard(level, scores)


func _on_bottom_world_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Ensure it's the player
		body.global_position = respawn_point

func set_checkpoint(new_checkpoint_position: Vector2) -> void:
	respawn_point = new_checkpoint_position


func _on_next_button_pressed():
	hide_leaderboard_container()
	current_level_number = (current_level_number % total_levels) + 1  # Cycle from 1 to 4
	var next_level_path = base_level_path + str(current_level_number) + ".tscn"
	
	if game:
		game.load_level(next_level_path)

func _on_reset_button_pressed():
	hide_leaderboard_container()
	var curr_level_path = base_level_path + str(current_level_number) + ".tscn"
	
	if game:
		game.load_level(curr_level_path)

func _on_previous_button_pressed():
	hide_leaderboard_container()
	current_level_number = (current_level_number - 2 + total_levels) % total_levels + 1  # Cycle backwards
	var previous_level_path = base_level_path + str(current_level_number) + ".tscn"
	
	if game:
		game.load_level(previous_level_path)

func _on_main_button_pressed():
	hide_leaderboard_container()
	MusicManager.play_random_menu_music()
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")

func _on_login_button_pressed():
	UIManager.show_login()


func player_replay():
	if not player or player.position_history.is_empty() or is_replaying:
		return

	pre_replay_position = player.global_position
	start_replay()
	replay_cancelled = false
	is_replaying = true
	skip_button.visible = true
	
	await async_replay(player.position_history, elapsed_time)

	end_replay()

	
func play_replay(positions: Array, total_replay_time: float):
	if not player or positions.is_empty():
		return

	pre_replay_position = player.global_position
	start_replay()
	replay_cancelled = false
	is_replaying = true
	skip_button.visible = true
	
	await async_replay(positions, total_replay_time, true)

	end_replay()


func async_replay(positions: Array, total_replay_time: float, is_external := false):
	for i in range(positions.size()):
		if replay_cancelled:
			break

		var pos_data = positions[i]
		var pos = Vector2(pos_data["x"], pos_data["y"]) if is_external else pos_data
		player.global_position = pos

		# Interpolate the time more accurately based on actual run duration
		var percent = float(i) / max(positions.size() - 1, 1)
		var display_time = total_replay_time * percent
		time_label.text = "Time: %.2f" % display_time

		await get_tree().create_timer(player.record_interval).timeout

	return null


func start_replay():
	player.zoom_out()
	player.set_physics_process(false)
	player.modulate = Color(1, 1, 1, 0.5)
	hide_leaderboard_container()
	#leaderboard.visible = false

func end_replay():
	player.zoom_in()
	player.set_physics_process(true)
	player.modulate = Color(1, 1, 1, 1)
	show_leaderboard_container()
	#leaderboard.visible = true
	is_replaying = false
	skip_button.visible = false

func _on_skip_button_pressed():
	replay_cancelled = true
	player.global_position = pre_replay_position


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


func _on_watch_replay_pressed(level_number: int, username: String) -> void:
	print("Requesting replay for %s..." % username)
	HTTPRequestManager.fetch_replay(level_number, username)

func _on_replay_received(replay_array: Array, completion_time: float) -> void:
	print("Starting replay! Recorded time: %.2f seconds" % completion_time)
	
	#await play_replay(replay_array, completion_time)
	if ghost_requested:
		game.set_ghost_replay(replay_array, completion_time)
		var current_level_path = base_level_path + str(current_level_number) + ".tscn"
		game.load_level(current_level_path)
	else:
		await play_replay(replay_array, completion_time)



func show_leaderboard_container():
	UIManager.show_leaderboard_container()

func hide_leaderboard_container():
	UIManager.hide_leaderboard_container()


func spawn_ghost(replay_data: Array, total_time: float):
	if ghost_player_scene:
		ghost_player = ghost_player_scene.instantiate()
		add_child(ghost_player)
		ghost_player.set_replay(replay_data, total_time)
		ghost_player.update_name(game.ghost_name)
		ghost_player.global_position = respawn_point 

func _on_ghost_replay_pressed(level_number: int, username: String) -> void:
	print("Requesting ghost replay for %s..." % username)
	ghost_requested = true
	game.set_ghost_name(username)
	HTTPRequestManager.fetch_replay(level_number, username)
