extends Node

var touch_controls_enabled = false
var admin_controls_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func toggle_touch_controls():
	touch_controls_enabled = !touch_controls_enabled

func toggle_admin_controls():
	admin_controls_enabled = !admin_controls_enabled
