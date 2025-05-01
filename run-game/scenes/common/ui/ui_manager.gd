extends CanvasLayer

var login_screen = null
var create_account_screen = null
var active_tween: Tween
var current_level: int = 1
var scoreboard_entry_scene = preload("res://scenes/common/ui/scoreboard_entry.tscn")
#@onready var leaderboard = $LevelUI/Leaderboard
#@onready var replay_button = $LevelUI/Leaderboard/VBoxContainer/ReplayButton
@onready var replay_button = $LeaderboardUI/ControlsContainer/ReplayButton
#@onready var login_button = $LevelUI/Leaderboard/VBoxContainer/LoginButton
@onready var login_button = $LeaderboardUI/ControlsContainer/LoginButton
@onready var skip_button = $LeaderboardUI/ControlsContainer/SkipButton
@onready var leaderboard_ui = $LeaderboardUI
@onready var scores_container = $LeaderboardUI/VBoxContainer/PanelContainer/VBoxContainer/ScoresContainer
@onready var leaderboard_container = $LeaderboardUI/VBoxContainer/PanelContainer
@onready var status_label = $LeaderboardUI/VBoxContainer/PanelContainer/VBoxContainer/StatusLabel
@onready var top_label = $LeaderboardUI/VBoxContainer/TopLabel
@onready var bottom_label = $LeaderboardUI/BottomLabel
@onready var login_layer = $LoginLayer
@onready var controls_container = $LeaderboardUI/ControlsContainer


signal watch_replay_pressed(level_number: int, username: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LevelUI.visible = false # Hide level UI when loaded


func show_login():
	hide_create_account()
	if login_screen == null:
		login_screen = load("res://scenes/common/ui/login_screen.tscn").instantiate()
		login_layer.add_child(login_screen)
		login_screen.login_success.connect(_on_login_success)
		login_screen.go_to_create_account.connect(show_create_account)

func show_create_account():
	hide_login()
	if create_account_screen == null:
		create_account_screen = load("res://scenes/common/ui/create_account_screen.tscn").instantiate()
		login_layer.add_child(create_account_screen)
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
	leaderboard_ui.visible = true
	hide_leaderboard_container()
	show_touch_controls()

func show_multiplayer_ui():
	$LevelUI.visible = true
	login_button.visible = false
	replay_button.visible = false
	skip_button.visible = false
	top_label.text = ""
	leaderboard_ui.visible = true
	show_touch_controls()

func show_touch_controls():
	$TouchControls.visible = true

func hide_level_ui():
	$LevelUI.visible = false
	#$LevelUI/Leaderboard.visible = false
	$LevelUI/ScoreboardLabel.visible = false
	hide_touch_controls()
	leaderboard_ui.visible = false

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
		
		var scoreboard_entry = scoreboard_entry_scene.instantiate()
		var rank_label = scoreboard_entry.get_node("HBoxContainer/RankLabel")
		var name_label = scoreboard_entry.get_node("HBoxContainer/NameLabel")
		var time_label = scoreboard_entry.get_node("HBoxContainer/TimeLabel")
		var button = scoreboard_entry.get_node("HBoxContainer/ReplayButton")
		
		var rank = i + 1
		rank_label.text = "%d." % rank
		name_label.text = username
		time_label.text = "%.2f s" % time
		
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		
		button.text = "Watch"
		#button.pressed.connect(_on_watch_replay_pressed.bind(level, username))
		button.pressed.connect(func(): emit_signal("watch_replay_pressed", level, username))
		#button.theme = preload("res://assets/themes/mush_theme.tres")
		
		
		# Color rank label for top 3
		match rank:
			1:
				#rank_label.add_theme_color_override("font_color", Color.hex(0xFFD700))  # Gold
				rank_label.add_theme_color_override("font_color", Color.GOLD)  # Gold
				name_label.add_theme_color_override("font_color", Color.GOLD)  # Gold
				time_label.add_theme_color_override("font_color", Color.GOLD)  # Gold
			2:
				#rank_label.add_theme_color_override("font_color", Color.hex(0xC0C0C0))  # Silver
				rank_label.add_theme_color_override("font_color", Color.LIGHT_STEEL_BLUE)  # Silver
				name_label.add_theme_color_override("font_color", Color.LIGHT_STEEL_BLUE)  # Silver
				time_label.add_theme_color_override("font_color", Color.LIGHT_STEEL_BLUE)  # Silver
			3:
				#rank_label.add_theme_color_override("font_color", Color.hex(0xCD7F32))  # Bronze
				rank_label.add_theme_color_override("font_color", Color.TAN)  # Bronze
				name_label.add_theme_color_override("font_color", Color.TAN)  # Bronze
				time_label.add_theme_color_override("font_color", Color.TAN)  # Bronze
		
		# Color current user
		var current_username = HTTPRequestManager.username
		
		if username == current_username:
			name_label.add_theme_color_override("font_color", Color.YELLOW)

		scores_container.add_child(scoreboard_entry)



func _on_watch_replay_pressed(level_number: int, username: String) -> void:
	print("Requesting replay for %s..." % username)
	HTTPRequestManager.fetch_replay(level_number, username)

func _on_replay_received(replay_array: Array) -> void:
	print("Starting replay!")
	#play_replay(replay_array)

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

func update_top_label(message: String):
	top_label.text = message

func append_top_label(message: String):
	top_label.text += message

func clear_top_label():
	top_label.text = ""

func hide_leaderboard_ui():
	leaderboard_ui.visible = false
