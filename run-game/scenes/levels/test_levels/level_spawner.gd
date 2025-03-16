extends Node2D

@export var level_chunks: Array[PackedScene] 
@export var chunk_spawn_distance := 1920.0  # How far ahead to spawn new chunks
@export var max_chunks := 5 

var active_chunks = []  # List of currently spawned chunks
var player

func _ready():
	player = get_tree().get_nodes_in_group("player")[-1] 
	spawn_initial_chunks()
	UIManager.hide_level_ui() # Make sure level UI is not visible
	#UIManager.get_node("FadeLayer").visible = false # For testing purposes

func _process(_delta):
	check_and_spawn_chunks()

# Spawn a few starting chunks
func spawn_initial_chunks():
	for i in range(3):
		spawn_new_chunk(Vector2(i * chunk_spawn_distance, 0))

# Spawns a new chunk at a given position
func spawn_new_chunk(position: Vector2):
	var chunk_scene = level_chunks.pick_random()
	var chunk_instance = chunk_scene.instantiate()
	chunk_instance.position = position
	add_child(chunk_instance)
	active_chunks.append(chunk_instance)

	# Remove old chunks if over limit
	if active_chunks.size() > max_chunks:
		var old_chunk = active_chunks.pop_front()
		old_chunk.queue_free()

# Check if the player is close to the end of the last chunk, then spawn a new one
func check_and_spawn_chunks():
	if active_chunks.size() == 0:
		return

	var last_chunk = active_chunks.back()
	var last_chunk_end_x = last_chunk.position.x + chunk_spawn_distance

	if player.position.x > last_chunk_end_x - chunk_spawn_distance:
		spawn_new_chunk(Vector2(last_chunk_end_x, 0))


func _on_main_menu_button_pressed() -> void:
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
