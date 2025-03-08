extends TextureRect

var button_positions = [ 
	Vector2(0.46, 0.14),  # Level 1
	Vector2(0.3, 0.3),  # Level 2
	Vector2(0.43, 0.4),   # Level 3
	Vector2(0.6, 0.32)   # Level 4
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(get_child_count()):
		var button = get_child(i)
		if button is TextureButton:
			button.position = button_positions[i] * size  # Scale to background size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(get_child_count()):
		var button = get_child(i)
		if button is TextureButton:
			button.position = button_positions[i] * size  # Update positions on resize


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")


func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_levels/level_1.tscn")


func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_levels/level_2.tscn")
