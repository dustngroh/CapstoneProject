extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Character1Holder/Character1/Camera2D.enabled = false
	$Character1Holder/Character1.gravity = 0
	
	$Character2Holder/Character2/Camera2D.enabled = false
	$Character2Holder/Character2.gravity = 0
	$Character2Holder/Character2.scale.x = -1
	
	$VBoxContainer/MuteButton.set_pressed_no_signal(MusicManager.is_muted)
	$VBoxContainer/TouchControlsButton.set_pressed_no_signal(Settings.touch_controls_enabled)
	$VBoxContainer/AdminControlsButton.set_pressed_no_signal(Settings.admin_controls_enabled)
	
	UIManager.visible = false # Hide the UI on main menu
	UIManager.get_node("Leaderboard").visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_new_game_button_pressed() -> void:
	MusicManager.play_music("res://assets/audio/music/Guifrog - Frog Punch.mp3")
	var game = get_tree().root.get_node("Game")  # Get the persistent Game scene
	if game:
		game.load_level("res://scenes/levels/main_levels/level_1.tscn")


func _on_continue_button_pressed() -> void:
	$VBoxContainer/ContinueButton/AudioStreamPlayer.play()


func _on_level_select_button_pressed() -> void:
	var game = get_tree().root.get_node("Game")  # Get the persistent Game scene
	if game:
		game.load_level("res://scenes/common/level_select/level_select.tscn")


func _on_mute_button_toggled(toggled_on: bool) -> void:
	MusicManager.toggle_mute()


func _on_touch_controls_button_toggled(toggled_on: bool) -> void:
	Settings.toggle_touch_controls()


func _on_admin_controls_button_toggled(toggled_on: bool) -> void:
	Settings.toggle_admin_controls()
