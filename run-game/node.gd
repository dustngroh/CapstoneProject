extends Node

var current_level = null

func _ready():
	load_level('res://tile_map_layer.tscn')

func load_level(level_path: String):
	await $FadeLayer.fade_in(1.0)  # Fade to black

	if current_level:
		current_level.queue_free()  # Remove the old level

	var new_level = load(level_path).instantiate()
	$LevelContainer.add_child(new_level)
	current_level = new_level
	
	# Find and connect the WinZone signal
	var win_zone = new_level.get_node_or_null("WinZone")  # Make sure WinZone is named correctly
	if win_zone:
		win_zone.win.connect(_on_level_completed)  # Connect the signal

	await get_tree().process_frame  # Ensures the new level is fully loaded
	await $FadeLayer.fade_out(1.0)  # Fade back in

func _on_level_completed():
	print("Player reached the win zone!")
	load_level("res://test_level.tscn")  # Change this dynamically later
