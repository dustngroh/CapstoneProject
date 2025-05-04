extends CanvasModulate


@export var cycle_time = 60.0  # Total time for full day-night cycle in seconds
var time_elapsed = 0.0

# Colors for each phase of the day
@export var sunrise_color: Color = Color(1.0, 0.7, 0.5)
@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var sunset_color: Color = Color(1.0, 0.5, 0.3)
@export var night_color: Color = Color(0.2, 0.2, 0.4)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	time_elapsed += delta
	var cycle_progress = fmod(time_elapsed, cycle_time) / cycle_time

	if cycle_progress < 0.25:
		# Sunrise -> Day
		color = sunrise_color.lerp(day_color, cycle_progress / 0.25)
	elif cycle_progress < 0.5:
		# Day -> Sunset
		color = day_color.lerp(sunset_color, (cycle_progress - 0.25) / 0.25)
	elif cycle_progress < 0.75:
		# Sunset -> Night
		color = sunset_color.lerp(night_color, (cycle_progress - 0.5) / 0.25)
	else:
		# Night -> Sunrise
		color = night_color.lerp(sunrise_color, (cycle_progress - 0.75) / 0.25)
