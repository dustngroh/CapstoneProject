extends Node

var current_level = null
@onready var fade_layer: CanvasLayer = UIManager.get_node("FadeLayer")

func _ready():
	load_level('res://scenes/main/MainMenu.tscn') # Load Main Menu on start

func load_level(level_path: String):
	# Fade to black
	await fade_layer.fade_in(1.0)

	if current_level:
		current_level.queue_free()  # Remove the old level

	var new_level = load(level_path).instantiate()
	$LevelContainer.add_child(new_level)
	current_level = new_level

	await get_tree().process_frame  # Ensures the new level is fully loaded
	
	#if level_path == "res://scenes/levels/main_levels/level_4.tscn": # Check if final level
		#MusicManager.play_music("res://assets/audio/music/Lite Saturation - Calm.mp3") # Play special song
		
	await fade_layer.fade_out(1.0)
