extends TextureRect

var triggered = false

func _on_main_menu_button_pressed() -> void:
	var game = get_tree().root.get_node_or_null("Game")
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
	else:
		print("Error: Game node not found!")


func _on_level_button_pressed(level_path: String) -> void:
	MusicManager.play_music("res://assets/audio/music/mushroom_background_music.mp3")

	var game = get_tree().root.get_node_or_null("Game")
	if game:
		if not triggered:
			game.load_level(level_path)
			triggered = true
	else:
		print("Error: Game node not found!")

# --- Functions for level button presses ---
func _on_level_1_button_pressed() -> void:
	_on_level_button_pressed("res://scenes/levels/main_levels/level_1.tscn")

func _on_level_2_button_pressed() -> void:
	_on_level_button_pressed("res://scenes/levels/main_levels/level_2.tscn")

func _on_level_3_button_pressed() -> void:
	_on_level_button_pressed("res://scenes/levels/main_levels/level_3.tscn")

func _on_level_4_button_pressed() -> void:
	_on_level_button_pressed("res://scenes/levels/main_levels/level_4.tscn")
