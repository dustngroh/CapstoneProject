extends CanvasLayer

var login_screen = null
var create_account_screen = null
var active_tween: Tween
var current_level: int = 1
@onready var leaderboard = $LevelUI/Leaderboard
@onready var replay_button = $LevelUI/Leaderboard/VBoxContainer/ReplayButton
@onready var login_button = $LevelUI/Leaderboard/VBoxContainer/LoginButton
@onready var leaderboard_ui = $LeaderboardUI
@onready var scores_container = $LeaderboardUI/PanelContainer/VBoxContainer/ScoresContainer
@onready var leaderboard_container = $LeaderboardUI/PanelContainer
@onready var status_label = $LeaderboardUI/PanelContainer/VBoxContainer/StatusLabel

signal watch_replay_pressed(level_number: int, username: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LevelUI.visible = false # Hide level UI when loaded


func show_login():
	hide_create_account()
	if login_screen == null:
		login_screen = load("res://scenes/common/ui/login_screen.tscn").instantiate()
		add_child(login_screen)
		login_screen.login_success.connect(_on_login_success)
		login_screen.go_to_create_account.connect(show_create_account)

func show_create_account():
	hide_login()
	if create_account_screen == null:
		create_account_screen = load("res://scenes/common/ui/create_account_screen.tscn").instantiate()
		add_child(create_account_screen)
		create_account_screen.account_created.connect(_on_account_created)
		create_account_screen.go_back_to_login.connect(show_login)

func _on_login_success(username):
	print("Logged in as:", username)
	hide_login()

func hide_login():
	if login_screen:
		login_screen.queue_free()
		login_screen = null

func hide_create_account():
	if create_account_screen:
		create_account_screen.queue_free()
		create_account_screen = null

func _on_account_created(username):
	print("Account created for:", username)
	show_login()
	if login_screen:
		login_screen.set_error_label("Account created for: " + username + ".\nPlease login now.")


func show_level_ui():
	$LevelUI.visible = true
	replay_button.visible = true
	show_touch_controls()

func show_multiplayer_ui():
	$LevelUI.visible = true
	login_button.visible = false
	replay_button.visible = false
	show_touch_controls()

func show_touch_controls():
	$TouchControls.visible = true

func hide_level_ui():
	$LevelUI.visible = false
	$LevelUI/Leaderboard.visible = false
	$LevelUI/ScoreboardLabel.visible = false
	hide_touch_controls()

func hide_touch_controls():
	$TouchControls.visible = false


func _on_failed_login(error):
	if login_screen:
		login_screen.set_error_label(error)

func _on_failed_register(error):
	if create_account_screen:
		create_account_screen.set_error_label(error)


func clear_leaderboard():
	for child in scores_container.get_children():
		scores_container.remove_child(child)
		child.queue_free()

func populate_leaderboard(level: int, scores: Array):
	current_level = level
	for i in range(scores.size()):
		var score = scores[i]
		var username = score["username"]
		var time = float(score["completion_time"]) / 100.0

		var hbox = HBoxContainer.new()

		var label = Label.new()
		label.text = "%d. %s - %.2f seconds" % [i + 1, username, time]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var button = Button.new()
		button.text = "Watch"
		#button.pressed.connect(_on_watch_replay_pressed.bind(level, username))
		button.pressed.connect(func(): emit_signal("watch_replay_pressed", level, username))
		button.theme = preload("res://assets/themes/mush_theme.tres")
		
		var current_username = HTTPRequestManager.username

		if username == current_username:
			label.add_theme_color_override("font_color", Color.YELLOW)
			#button.add_theme_color_override("font_color", Color.YELLOW)

		hbox.add_child(label)
		hbox.add_child(button)

		scores_container.add_child(hbox)



func _on_watch_replay_pressed(level_number: int, username: String) -> void:
	print("Requesting replay for %s..." % username)
	HTTPRequestManager.fetch_replay(level_number, username)

func _on_replay_received(replay_array: Array) -> void:
	print("Starting replay!")
	#play_replay(replay_array)
	# Here you can instantiate a ghost player and play the replay_array

func show_leaderboard_container():
	leaderboard_container.visible = true
	leaderboard_container.modulate = Color(1, 1, 1, 0)
	if active_tween:
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.tween_property(leaderboard_container, "modulate:a", 1.0, 3.0)

func hide_leaderboard_container():
	if active_tween:
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.tween_property(leaderboard_container, "modulate:a", 0.0, 0.5)
	leaderboard_container.visible = false

func update_status(status_message: String):
	status_label.text = status_message

func hide_leaderboard_ui():
	leaderboard_ui.visible = false
