extends Node2D
@export var offset = Vector2(0, -320)
@export var duration = 5.0
var tween: Tween

func _ready():
	start_tween()

func start_tween():
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	tween.tween_property($AnimatableBody2D, "position", offset, duration / 2)
	tween.tween_property($AnimatableBody2D, "position", Vector2.ZERO, duration / 2)

func _exit_tree():
	if tween:
		tween.kill()
