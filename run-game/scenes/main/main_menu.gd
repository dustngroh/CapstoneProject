extends Control

@onready var login_button = $MiddleContainer/MenuButtonContainer/LoginScreenButton
@onready var logout_button = $MiddleContainer/MenuButtonContainer/LogoutButton
@onready var create_account_button = $MiddleContainer/MenuButtonContainer/CreateAccountScreenButton
@onready var mute_button = $MiddleContainer/MenuButtonContainer/MuteButton
@onready var info_label = $MiddleContainer/InfoLabel
@onready var game = get_tree().root.get_node("Game")

var is_loading_level = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	mute_button.set_pressed_no_signal(MusicManager.is_muted)
	
	UIManager.hide_level_ui()
	HTTPRequestManager.login_success.connect(_on_successful_login)
	HTTPRequestManager.register_success.connect(_on_account_creation)
	HTTPRequestManager.login_failed.connect(_on_failed_login)
	HTTPRequestManager.register_failed.connect(_on_failed_register)
	
	var logged_in = HTTPRequestManager.is_logged_in()
	
	update_login_buttons(logged_in)


func _on_new_game_button_pressed() -> void:
	if is_loading_level:
		return  # Already loading, ignore extra presses
	
	is_loading_level = true
	MusicManager.play_music("res://assets/audio/music/mushroom_background_music.mp3")
	#var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/levels/main_levels/level_1.tscn")


func _on_level_select_button_pressed() -> void:
	if is_loading_level:
		return  # Already loading, ignore extra presses
	
	is_loading_level = true
	#var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/common/level_select/level_select.tscn")


func _on_mute_button_toggled(toggled_on: bool) -> void:
	MusicManager.toggle_mute()


func _on_login_screen_button_pressed() -> void:
	UIManager.show_login()


func _on_create_account_screen_button_pressed() -> void:
	UIManager.show_create_account()


func _on_endless_run_button_pressed() -> void:
	if is_loading_level:
		return  # Already loading, ignore extra presses
	
	is_loading_level = true
	MusicManager.play_music("res://assets/audio/music/Maarten Schellekens - Ulua Beach.mp3")
	#var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/levels/alternate_levels/endless_run.tscn")


func _on_multiplayer_button_pressed() -> void:
	if is_loading_level:
		return  # Already loading, ignore extra presses
	
	is_loading_level = true
	#var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/common/ui/multiplayer_screen.tscn")


func _on_tutorial_button_pressed() -> void:
	if is_loading_level:
		return  # Already loading, ignore extra presses
	
	is_loading_level = true
	if game:
		game.load_level("res://scenes/levels/alternate_levels/tutorial_level.tscn")


func _on_successful_login(user) -> void:
	UIManager.hide_login()
	#info_label = user + " logged in."
	#$VBoxContainer2/LogoutButton.visible = true
	update_login_buttons(true)

func _on_account_creation(user) -> void:
	UIManager._on_account_created(user)

func _on_failed_login(error) -> void:
	UIManager._on_failed_login(error)
	
func _on_failed_register(error) -> void:
	UIManager._on_failed_register(error)

func _on_logout_button_pressed() -> void:
	info_label.text = HTTPRequestManager.username + " logged out."
	HTTPRequestManager.clear_token()
	#$VBoxContainer/MainMenuLabel.text = "Logged out."
	#$VBoxContainer2/LogoutButton.visible = false
	update_login_buttons(false)

func update_login_buttons(logged_in):
	logout_button.visible = logged_in
	login_button.visible = !logged_in
	#$VBoxContainer2/CreateAccountScreenButton.visible = !logged_in
	
	if logged_in:
		info_label.text = "Welcome, " + HTTPRequestManager.username + "."
