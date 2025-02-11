extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
@export var push_force = 200.0
@export var speed = 1000
@export var jump_speed = -1000
@export var gravity = 2000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.04

@export var dash_dance_grace_time = 0.05  # Time window for lenient direction switch
@export var speed_threshold = 0.9  # Percentage of full speed required to trigger instant flip

var last_direction = 0
var last_direction_time = 0.0

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	var dir = Input.get_axis("walk_left", "walk_right")
	if dir != 0:
		#velocity.x = lerp(velocity.x, dir * speed, acceleration)
		var is_flipping_direction = last_direction != 0 and dir != last_direction
		var within_grace_time = (Time.get_ticks_msec() - last_direction_time) / 1000.0 <= dash_dance_grace_time
		var at_high_speed = abs(velocity.x) >= speed * speed_threshold

		# If flipping direction at high speed within grace time, do instant switch
		if is_flipping_direction and within_grace_time and at_high_speed:
			velocity.x = dir * speed  # Instant switch
		else:
			velocity.x = lerp(velocity.x, dir * speed, acceleration)
		# Update last direction
		last_direction = dir
		last_direction_time = Time.get_ticks_msec()
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	move_and_slide()
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
