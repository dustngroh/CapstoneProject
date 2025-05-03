extends RigidBody2D

var time_offset = 0.0
@export var radius = 30.0
@export var speed = 1.5
@export var vertical_scale = 1.0
@export var horizontal_scale = 1.0
@export var max_force = 300.0
var base_position: Vector2
var motion_time := 0.0

func _ready():
	time_offset = randf_range(0.0, TAU)
	base_position = global_position


func _physics_process(delta):
	motion_time += delta
	var t = motion_time * speed + time_offset

	var desired_offset = Vector2(
		cos(t) * radius * horizontal_scale,
		sin(t) * radius * vertical_scale
	)
	
	var desired_position = base_position + desired_offset
	var direction = desired_position - global_position
	var distance = direction.length()

	# Clamp the max force strength to avoid crazy physics
	var force_strength = clamp(distance * 20.0, 0.0, max_force)
	
	var force = direction.normalized() * force_strength
	apply_force(force)
