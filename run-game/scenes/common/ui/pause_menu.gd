extends Control

@onready var pause_menu = $"."

func _ready():
	pause_menu.hide()  # Hide menu initially

func toggle_pause():
	if pause_menu.visible:
		pause_menu.hide()
		get_tree().paused = false
	else:
		pause_menu.show()
		get_tree().paused = true

func _input(event):
	if event.is_action_pressed("esc"): 
		toggle_pause()

func _on_resume_button_pressed():
	toggle_pause()

func _on_quit_button_pressed():
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	toggle_pause()
	WebSocketManager.disconnect_from_server()
	MusicManager.play_random_menu_music()
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
