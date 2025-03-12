extends CanvasLayer


@onready var color_rect = $ColorRect

func fade_in(duration = 1.0):
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_out(duration = 1.0):
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
