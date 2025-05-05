extends Node

var current_level = null
@onready var fade_layer: CanvasLayer = UIManager.get_node("FadeLayer")

var ghost_replay_data: Array = []
var ghost_total_time: float = 0.0
var should_spawn_ghost: bool = false
var ghost_name: String = ""

func _ready():
	load_level('res://scenes/main/MainMenu.tscn') # Load Main Menu on start
	#load_level('res://scenes/levels/main_levels/level_thi.tscn') # Uncomment this and change path to your level

func load_level(level_path: String):
	# Fade to black
	await fade_layer.fade_in(1.0)
	
	if level_path == "":
		print("Invalid path. Load failed: empty string.")
		return

	var scene_resource = load(level_path)
	if scene_resource == null:
		print("Failed to load scene from path:", level_path)
		return

	if current_level:
		current_level.queue_free()  # Remove the old level
	
	var new_level = scene_resource.instantiate()
	$LevelContainer.add_child(new_level)
	current_level = new_level

	await get_tree().process_frame  # Ensures the new level is fully loaded
	
	await fade_layer.fade_out(1.0)

func set_ghost_replay(data: Array, total_time: float):
	print("setting ghost")
	ghost_replay_data = data
	ghost_total_time = total_time
	should_spawn_ghost = true

func set_ghost_name(name: String):
	ghost_name = name
