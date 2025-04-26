extends Area2D

@export var mushroom_scene: PackedScene = preload("res://scenes/entities/obstacles/mushroom_bounce.tscn")
@export var spawn_count: int = 10
@export var left_edge: float = 300.0  # How far from center left edge of spawn area
@export var right_edge: float = 1000.0  # How far from center right edge of spawn area
@export var bottom_edge: float = -400.0  # Bottom edge of spawn area
@export var top_edge: float = -600.0  # Top edge of spawn area

var triggered = false

func spawn_mushrooms():
	for i in range(spawn_count):
		var mushroom = mushroom_scene.instantiate()
		
		var random_offset = Vector2(randf_range(left_edge, right_edge), 0)
		var spawn_position = global_position + random_offset + Vector2(0, randf_range(bottom_edge, top_edge))
		
		get_parent().add_child(mushroom)
		mushroom.global_position = spawn_position


func _on_body_entered(body: Node2D) -> void:
	if !triggered:
		if body.is_in_group("player"):
			triggered = true
			call_deferred("spawn_mushrooms")
