extends Node2D

@export var obstacle_scenes: Array[PackedScene]

func _ready():
	if obstacle_scenes.size() > 0:
		var chance = randf() # Random spawn chance
		if chance <= 0.2:
			var obstacle = obstacle_scenes.pick_random().instantiate()
			#obstacle.add_to_group("movable_objects")
			add_child(obstacle)
			obstacle.position = Vector2(randf_range(100, 500), 0)  # Randomize position
