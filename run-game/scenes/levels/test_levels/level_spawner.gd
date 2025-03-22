extends Node2D

@export var level_chunks: Array[PackedScene] 
@export var chunk_spawn_distance := 1920.0  # How far ahead to spawn new chunks
@export var max_chunks := 5 
@export var RESET_THRESHOLD = 30720  # Reset world when the player crosses this point
@export var shift_amount = 30720

var active_chunks = []  # List of currently spawned chunks
var player
var camera : Camera2D

func _ready():
	player = get_tree().get_nodes_in_group("player")[-1] 
	camera = player.get_node("Camera2D")
	spawn_initial_chunks()
	UIManager.hide_level_ui() # Make sure level UI is not visible
	#UIManager.get_node("FadeLayer").visible = false # For testing purposes

func _process(_delta):
	check_and_spawn_chunks()
	recenter_world_if_needed()

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

# Recenter world to avoid floating point precision errors in physics beyond threshold
func recenter_world_if_needed():
	if player.position.x > RESET_THRESHOLD:
		
		# Move player back
		player.position.x -= shift_amount

		# Move all active chunks back
		for chunk in active_chunks:
			chunk.position.x -= shift_amount
		
		# Force camera to remain centered left of player
		player.position.x -= 500 # Move player left an extra amount
		camera.force_update_scroll() # Force camera onto them
		player.position.x += 500 # Move player back right same amount

func _on_main_menu_button_pressed() -> void:
	MusicManager.play_music("res://assets/audio/music/Lite Saturation - Calm.mp3")
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
