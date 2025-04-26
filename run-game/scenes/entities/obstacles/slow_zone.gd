extends Area2D

@export var slow_factor: float = 0.5
@export var length = 600
@export var height = 250


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CollisionShape2D.shape.size = Vector2(length, height)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.enter_slow_zone(slow_factor)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.exit_slow_zone()
