extends Control

signal move_left_pressed
signal move_right_pressed
signal jump_pressed
signal move_left_released
signal move_right_released


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_left_button_button_down() -> void:
	emit_signal('move_left_pressed')


func _on_left_button_button_up() -> void:
	emit_signal('move_left_released')


func _on_right_button_button_down() -> void:
	emit_signal('move_right_pressed')


func _on_right_button_button_up() -> void:
	emit_signal('move_right_released')


func _on_jump_button_pressed() -> void:
	emit_signal('jump_pressed')
