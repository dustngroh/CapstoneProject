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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position_sprite_to_bottom()
	resize_background()
	get_viewport().size_changed.connect(on_size_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_day_cycle(delta)


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
