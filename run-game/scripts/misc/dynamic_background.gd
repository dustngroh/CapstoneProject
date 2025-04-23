extends CanvasModulate

@export var darken_duration = 10.0  # seconds
var elapsed_time = 0.0
@export var start_color: Color = Color(1, 1, 1)
@export var end_color: Color = Color(1, 1, 1)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if elapsed_time < darken_duration:
		elapsed_time += delta
		var progress = clamp(elapsed_time / darken_duration, 0, 1)

		color = start_color.lerp(end_color, progress)
