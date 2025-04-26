extends CharacterBody2D


@export var normal_speed = 800
var speed = normal_speed
@export var max_speed = 3000
@export var jump_speed = -1000
@export var gravity = 2000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.04
@export var collision_slowdown_factor = 0.5  # How much collisions slow player
@export var push_force = 200.0  # Strength of push-back
@export var push_back_duration = 0.2  # Duration of the push-back in seconds
@export var dash_dance_grace_time = 0.05  # Time window for lenient direction switch
@export var speed_threshold = 0.9  # Percentage of full speed required to trigger instant flip
var speed_boost_timer = 0.0

var last_direction = 0
var last_direction_time = 0.0

# Coyote time
@export var coyote_frames = 12  # How many in-air frames to allow jumping
var coyote = false  # Track whether we're in coyote time or not
var last_floor = false  # Last frame's on-floor state
var jumping = false

# Camera
@export var zoom_in_factor = 1.5
@export var zoom_in_duration = 3.0
var zooming = false
var active_tween: Tween = null

# Recording
var position_history: Array = []  # Stores recorded positions
var recording: bool = false  # Flag to enable/disable recording
@export var record_interval: float = 0.1  # Time interval in seconds
var record_timer: float = 0.0  # Timer for position recording
@export var max_replay_duration: float = 300.0  # Max 5 minutes
var replay_time_elapsed: float = 0.0

# Collision
var is_pushed_back = false
var push_back_timer = 0.0
var push_back_direction = Vector2.ZERO
var original_velocity = Vector2.ZERO

func _ready() -> void:
	$CoyoteTimer.wait_time = coyote_frames / 60.0

func _physics_process(delta: float) -> void:
	
	# Position Recording
	if recording:
		replay_time_elapsed += delta
		record_timer += delta
		if replay_time_elapsed >= max_replay_duration:
			end_recording()
		elif record_timer >= record_interval:
			record_timer = 0.0
			position_history.append(global_position)
	
	# Speed boost handling
	if speed_boost_timer > 0:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			reset_speed()
	
	velocity.y += gravity * delta
	var dir = Input.get_axis("walk_left", "walk_right")
	
	# Apply push-back if the timer is running
	if is_pushed_back:
		push_back_timer -= delta
		if push_back_timer > 0:
			velocity = velocity * (1 - collision_slowdown_factor) + push_back_direction * push_force
		
		else:
			is_pushed_back = false  # Stop pushing when time is up
	
	# Determine animation state
	if !is_on_floor():  
		$AnimatedSprite2D.play("jumping")  # Play jump animation when airborne
	#elif Input.is_action_pressed("hold_down"):
		#$AnimatedSprite2D.play("down")  # Play crouch animation
	elif dir != 0:
		$AnimatedSprite2D.play("walking")
		$AnimatedSprite2D.speed_scale = abs(velocity.x) / normal_speed  # Adjust speed of animation
	else:
		$AnimatedSprite2D.speed_scale = lerp($AnimatedSprite2D.speed_scale, 0.0, 0.1) # Stop animation when idle
	
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
	
	velocity.x = clamp(velocity.x, -max_speed, max_speed) # Make sure velocity does not exceed max_speed
	
	move_and_slide()
	
	# Check for collisions
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var collision_normal = c.get_normal()
			var velocity_along_normal = velocity.dot(collision_normal)
			
			if c.get_collider().is_in_group("rocks"):
				# rocks slow player and get pushed
				velocity -= collision_normal * velocity_along_normal * (1 - collision_slowdown_factor)
				c.get_collider().apply_central_impulse(-collision_normal * push_force)
			
			else:
				# Other obstacles also apply push-back
				# Apply slowdown for collision along the normal direction
				velocity -= collision_normal * velocity_along_normal * (1 - collision_slowdown_factor)
				# Apply a force to the collided object
				c.get_collider().apply_central_impulse(-collision_normal * push_force)
				
				# Apply push-back to player
				if abs(collision_normal.x) > 0.5:  # Only consider collisions along the x-axis
					if not is_pushed_back:
						is_pushed_back = true
						push_back_direction = collision_normal  # Set the direction to push the player back
						push_back_timer = push_back_duration  # Reset the push-back timer
						original_velocity = velocity  # Store the current velocity before push-back
	
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

func zoom_in():
	if active_tween:
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.tween_property($Camera2D, "zoom", Vector2(zoom_in_factor, zoom_in_factor), zoom_in_duration)

func zoom_out():
	if active_tween:
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.tween_property($Camera2D, "zoom", Vector2(1, 1), 0.5)

# Function to zoom out the camera when bouncing on spring
func zoom_out_effect():
	if not zooming:
		zooming = true
		if active_tween:
			active_tween.kill()
		# Zoom out the camera smoothly
		active_tween = create_tween()
		active_tween.tween_property($Camera2D, "zoom", Vector2(0.7, 0.7), 0.8)
		#$Camera2D.zoom = Vector2(0.5, 0.5)
		#await get_tree().create_timer(1.5).timeout
		#$Camera2D.zoom = Vector2(1, 1)
		#var parallax = get_parent().get_node("Parallax2D") 
		#if parallax:
			#var viewport_size = get_viewport().size
			#active_tween.tween_property(parallax, "screen_offset", Vector2(-0.5 * viewport_size.x, -0.5 * viewport_size.y), 0.5)
			#active_tween.tween_property(parallax, "scale", Vector2(2, 2), 0.5)
			#active_tween.tween_property(parallax, "", Vector2(2, 2), 0.5)
			
		# Then zoom back in
		await(active_tween.finished)
		zoom_in_effect()

# Function to zoom back in when bouncing on spring
func zoom_in_effect():
	if active_tween:
		active_tween.kill()
	# Zoom back in slowly
	active_tween = create_tween()
	active_tween.tween_property($Camera2D, "zoom", Vector2(1, 1), 2.0)
	
	zooming = false


# Function to record one final location and stop recording
func end_recording():
	if recording:
		position_history.append(global_position)
		recording = false
