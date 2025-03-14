extends CharacterBody2D


@export var push_force = 200.0

@export var normal_speed = 800
var speed = normal_speed
@export var jump_speed = -1000
@export var gravity = 2000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.04

@export var dash_dance_grace_time = 0.05  # Time window for lenient direction switch
@export var speed_threshold = 0.9  # Percentage of full speed required to trigger instant flip
var speed_boost_timer = 0.0

var last_direction = 0
var last_direction_time = 0.0

@export var coyote_frames = 12  # How many in-air frames to allow jumping
var coyote = false  # Track whether we're in coyote time or not
var last_floor = false  # Last frame's on-floor state
var jumping = false


func _ready() -> void:
	$CoyoteTimer.wait_time = coyote_frames / 60.0

func _physics_process(delta: float) -> void:
	
	if speed_boost_timer > 0:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			reset_speed()
	
	velocity.y += gravity * delta
	var dir = Input.get_axis("walk_left", "walk_right")
	
	
	# Determine animation state
	if !is_on_floor():  
		$AnimatedSprite2D.play("jump")  # Play jump animation when airborne
	elif Input.is_action_pressed("hold_down"):
		$AnimatedSprite2D.play("down")  # Play crouch animation
	elif dir != 0:
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.speed_scale = abs(velocity.x) / normal_speed  # Adjust speed of animation
	else:
		$AnimatedSprite2D.play("default")
		$AnimatedSprite2D.speed_scale = 1.0  # Reset for idle
	
	if dir != 0:
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
	
	# Check for jump
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote):
		velocity.y = jump_speed
		jumping = true
	
	move_and_slide()

	# Check for collisions
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
			
	# Update jumping
	if is_on_floor() and jumping:
		jumping = false
	
	# Check for coyote time
	if !is_on_floor() and last_floor and !jumping:
		coyote = true
		#modulate = 0xff00ff # Uncomment to apply a color filter when coyote is active
		$CoyoteTimer.start()
	
	# Update sprite direction
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	
	# Set last_floor
	last_floor = is_on_floor()

func increase_speed(boost_amount, duration):
	speed *= boost_amount
	speed_boost_timer = duration

func reset_speed():
	speed = normal_speed


func _on_coyote_timer_timeout() -> void:
	coyote = false
	#modulate = Color(1, 1, 1) # Uncomment to use coyote color filter (removes filter)
