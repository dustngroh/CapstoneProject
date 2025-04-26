extends TextureRect

var button_positions = [ 
	Vector2(0.1, 0.56),  # Level 1
	Vector2(0.25, 0.7),  # Level 2
	Vector2(0.75, 0.6),   # Level 3
	Vector2(0.9, 0.6)   # Level 4
]

var level_positions = [
	Vector2(150, -250),  # Level 1
	Vector2(225, -315), # Level 2
	Vector2(-475, -295), # Level 3
	Vector2(-585, -295)  # Level 4
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CharacterBody2D/Camera2D.enabled = false
	update_button_positions()
	get_viewport().size_changed.connect(update_button_positions)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_main_menu_button_pressed() -> void:
	var game = get_tree().root.get_node_or_null("Game")
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
	else:
		print("Error: Game node not found!")


func _on_level_button_pressed(level_path: String) -> void:
	MusicManager.play_music("res://assets/audio/music/Guifrog - Frog Punch.mp3")

	var game = get_tree().root.get_node_or_null("Game")
	if game:
		game.load_level(level_path)
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


func _on_bottom_world_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Ensure it's the player
		body.position = $SpawnPoint.position  # Respawn at the spawn point

func update_button_positions():
	for i in range(get_child_count()):
		var button = get_child(i)
		if button is TextureButton:
			button.position = button_positions[i] * size  # Update positions on resize
			#button.position += level_positions[i]
