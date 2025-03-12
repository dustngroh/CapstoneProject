extends CanvasLayer

@export var next_level: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_results(level):
	next_level = level
	self.visible = true

func _on_next_level_button_pressed() -> void:
	if next_level == "res://scenes/levels/main_levels/level_4.tscn":
		MusicManager.play_music("res://assets/audio/music/Lite Saturation - Calm.mp3")
	#get_tree().change_scene_to_file(next_level)
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level(next_level)


func _on_main_menu_button_pressed() -> void:
	MusicManager.play_music("res://assets/audio/music/Lite Saturation - Calm.mp3")
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
	#get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
