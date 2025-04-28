extends Node2D

var cycle_time = 60.0  # Total duration of a full day-night cycle (seconds)
var time_elapsed = 0.0
var fade_duration = 2.0
var fade_progress = 0.0
var fading = false
var current_texture : Texture2D = null
var fading_to_texture : Texture2D = null

var sunrise_color = Color(1.0, 0.7, 0.4)    # warm orange
var day_color = Color(1.0, 1.0, 1.0)        # neutral light
var sunset_color = Color(1.0, 0.5, 0.3)     # deeper orange/red
var night_color = Color(0.2, 0.2, 0.4)      # dark bluish

var sunrise_texture = preload("res://assets/level/backgrounds/level bkgd sunrise.jpg")
var day_texture = preload("res://assets/level/backgrounds/level bkgd demo.jpg")
var sunset_texture = preload("res://assets/level/backgrounds/level bkgd sunset.jpg")
var night_texture = preload("res://assets/level/backgrounds/level bkgd night.jpg")

@onready var day_cycle_modulate: CanvasModulate = $DayCycleModulate
@onready var background_a = $Background/Sprite2D
@onready var background_b = $Background/Sprite2D2
@onready var level_spawner = $LevelSpawner
@onready var distance_label = $EndlessRunUI/DistanceLabel
@onready var login_button = $EndlessRunUI/VBoxContainer/Buttons/LoginButton

var distance_traveled: int = 0
var submit_timer: float = 0.0
var submit_interval: float = 10.0  # How often to submit distance (seconds)
var player: CharacterBody2D
var leaderboard_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position_sprite_to_bottom()
	resize_background()
	get_viewport().size_changed.connect(on_size_changed)
	UIManager.show_touch_controls()
	
	player = $Player
	leaderboard_label = $EndlessRunUI/VBoxContainer/Leaderboard
	leaderboard_label.text = "Leaderboard loading..."
	
	login_button.pressed.connect(_on_login_button_pressed)
	var logged_in = HTTPRequestManager.is_logged_in()
	
	if !logged_in:
		login_button.visible = true
		HTTPRequestManager.login_success.connect(_on_login_success)
		HTTPRequestManager.register_success.connect(_on_account_creation)
		HTTPRequestManager.login_failed.connect(_on_failed_login)
		HTTPRequestManager.register_failed.connect(_on_failed_register)
	
	HTTPRequestManager.endless_leaderboard_received.connect(update_leaderboard)
	HTTPRequestManager.endless_distance_submitted.connect(submission_successful)

	# Fetch the initial leaderboard
	HTTPRequestManager.fetch_endless_leaderboard()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_day_cycle(delta)
	
	if player:
		distance_traveled = int((level_spawner.total_distance_traveled + player.position.x) / 100)
		distance_label.text = "Distance: %d units" % distance_traveled
		submit_timer += delta
		if submit_timer >= submit_interval:
			submit_timer = 0.0
			submit_distance()


func submit_distance():
	print("Submitting distance: ", distance_traveled)
	HTTPRequestManager.submit_endless_distance(distance_traveled)


func update_leaderboard(scores: Array):
	var leaderboard_text = "🏆 Endless Leaderboard 🏆\n"

	for score in scores:
		var username = score.get("username", "???")
		var distance = score.get("distance", 0)
		leaderboard_text += "%s - %d units\n" % [username, distance]

	leaderboard_label.text = leaderboard_text

func submission_successful():
	HTTPRequestManager.fetch_endless_leaderboard()

func update_day_cycle(delta):
	time_elapsed += delta
	var target_texture : Texture2D
	var cycle_progress = fmod(time_elapsed, cycle_time) / cycle_time

	if cycle_progress < 0.25:
		# Sunrise -> Day
		day_cycle_modulate.color = sunrise_color.lerp(day_color, cycle_progress / 0.25)
		target_texture = sunrise_texture
	elif cycle_progress < 0.5:
		# Day -> Sunset
		day_cycle_modulate.color = day_color.lerp(sunset_color, (cycle_progress - 0.25) / 0.25)
		target_texture = day_texture
	elif cycle_progress < 0.75:
		# Sunset -> Night
		day_cycle_modulate.color = sunset_color.lerp(night_color, (cycle_progress - 0.5) / 0.25)
		target_texture = sunset_texture
	else:
		# Night -> Sunrise
		day_cycle_modulate.color = night_color.lerp(sunrise_color, (cycle_progress - 0.75) / 0.25)
		target_texture = night_texture
		
	if target_texture != current_texture and not fading:
		fading = true
		fade_progress = 0.0
		fading_to_texture = target_texture

		# Prepare background B
		background_b.texture = target_texture
		background_b.modulate.a = 0.0  # fully transparent
		
	if fading:
		fade_progress += delta
		var t = fade_progress / fade_duration
		background_b.modulate.a = clamp(t, 0, 1)

		if t >= 1.0:
			# Fade complete — make B the new main background
			background_a.texture = fading_to_texture
			background_a.modulate.a = 1.0
			background_b.modulate.a = 0.0
			fading = false
			current_texture = fading_to_texture


func position_sprite_to_bottom():
	var screen_height = get_viewport().get_visible_rect().size.y
	var grass_sprite = $Grass/Sprite2D
	var trees_sprite = $Trees/Sprite2D
	var grass_sprite_height = grass_sprite.texture.get_height() * grass_sprite.scale.y
	var trees_sprite_height = trees_sprite.texture.get_height() * trees_sprite.scale.y

	grass_sprite.position.y = screen_height - grass_sprite_height
	trees_sprite.position.y = screen_height - trees_sprite_height


func resize_background():
	var screen_size = get_viewport().get_visible_rect().size
	var texture_size = $Background/Sprite2D.texture.get_size()

	# First: scale by Y to maintain aspect ratio
	var scale_y = screen_size.y / texture_size.y
	var scaled_width = texture_size.x * scale_y

	# Check if X does not fill screen
	if scaled_width < screen_size.x:
		# Scale by X instead
		var scale_x = screen_size.x / texture_size.x
		$Background/Sprite2D.scale = Vector2(scale_x, scale_x)
		$Background/Sprite2D2.scale = Vector2(scale_x, scale_x)
	else:
		$Background/Sprite2D.scale = Vector2(scale_y, scale_y)
		$Background/Sprite2D2.scale = Vector2(scale_y, scale_y)


func on_size_changed():
	position_sprite_to_bottom()
	resize_background()

func _on_login_button_pressed():
	UIManager.show_login()

func _on_login_success(user) -> void:
	UIManager.hide_login()
	login_button.visible = false
	submit_distance()
	print("Logged in!")

func _on_account_creation(user) -> void:
	UIManager._on_account_created(user)

func _on_failed_login(error) -> void:
	UIManager._on_failed_login(error)
	
func _on_failed_register(error) -> void:
	UIManager._on_failed_register(error)
