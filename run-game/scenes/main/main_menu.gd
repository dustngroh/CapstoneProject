extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Character1Holder/Character1/Camera2D.enabled = false
	$Character1Holder/Character1.gravity = 0
	
	$Character2Holder/Character2/Camera2D.enabled = false
	$Character2Holder/Character2.gravity = 0
	$Character2Holder/Character2.scale.x = -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_new_game_button_pressed() -> void:
	MusicManager.play_music("res://assets/audio/music/Guifrog - Frog Punch.mp3")
	get_tree().change_scene_to_file("res://scenes/levels/main_levels/level_1.tscn")


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.


func _on_level_select_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/common/level_select/level_select.tscn")
