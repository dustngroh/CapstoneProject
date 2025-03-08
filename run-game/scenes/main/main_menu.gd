extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/test_levels/tile_map_layer.tscn")


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.


func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/common/level_select/level_select.tscn")
