extends Area2D

signal win
var win_zone_triggered: bool = false # Makes sure winzone only triggers once

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player') and not win_zone_triggered:
		win_zone_triggered = true
		$AudioStreamPlayer.play()
		emit_signal('win')
	
