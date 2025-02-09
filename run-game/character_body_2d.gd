extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
@export var push_force = 200.0
@export var speed = 1000
@export var jump_speed = -1000
@export var gravity = 2000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.08


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	var dir = Input.get_axis("walk_left", "walk_right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	move_and_slide()
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
