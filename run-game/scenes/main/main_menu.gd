extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$VBoxContainer/MuteButton.set_pressed_no_signal(MusicManager.is_muted)
	$VBoxContainer/TouchControlsButton.set_pressed_no_signal(Settings.touch_controls_enabled)
	$VBoxContainer/AdminControlsButton.set_pressed_no_signal(Settings.admin_controls_enabled)
	
	UIManager.hide_level_ui()
	HTTPRequestManager.login_success.connect(_on_successful_login)
	HTTPRequestManager.register_success.connect(_on_account_creation)
	HTTPRequestManager.login_failed.connect(_on_failed_login)
	HTTPRequestManager.register_failed.connect(_on_failed_register)
	
	$VBoxContainer2/LogoutButton.visible = HTTPRequestManager.is_logged_in()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_new_game_button_pressed() -> void:
	MusicManager.play_music("res://assets/audio/music/Guifrog - Frog Punch.mp3")
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/levels/main_levels/level_1.tscn")


func _on_continue_button_pressed() -> void:
	$VBoxContainer/ContinueButton/AudioStreamPlayer.play()


func _on_level_select_button_pressed() -> void:
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/common/level_select/level_select.tscn")


func _on_mute_button_toggled(toggled_on: bool) -> void:
	MusicManager.toggle_mute()


func _on_touch_controls_button_toggled(toggled_on: bool) -> void:
	Settings.toggle_touch_controls()


func _on_admin_controls_button_toggled(toggled_on: bool) -> void:
	Settings.toggle_admin_controls()


func _on_login_screen_button_pressed() -> void:
	UIManager.show_login()


func _on_create_account_screen_button_pressed() -> void:
	UIManager.show_create_account()


func _on_endless_run_button_pressed() -> void:
	MusicManager.play_music("res://assets/audio/music/Maarten Schellekens - Ulua Beach.mp3")
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/levels/alternate_levels/endless_run.tscn")


func _on_multiplayer_button_pressed() -> void:
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/common/ui/multiplayer_screen.tscn")

func _on_successful_login(user) -> void:
	UIManager.hide_login()
	$VBoxContainer/MainMenuLabel.text = user + " logged in."
	$VBoxContainer2/LogoutButton.visible = true

func _on_account_creation(user) -> void:
	UIManager._on_account_created(user)

func _on_failed_login(error) -> void:
	UIManager._on_failed_login(error)
	
func _on_failed_register(error) -> void:
	UIManager._on_failed_register(error)

func _on_logout_button_pressed() -> void:
	HTTPRequestManager.clear_token()
	$VBoxContainer/MainMenuLabel.text = "Logged out."
	$VBoxContainer2/LogoutButton.visible = false
