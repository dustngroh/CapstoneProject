extends Area2D

signal win
var win_zone_triggered: bool = false # Makes sure winzone only triggers once


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player') and not win_zone_triggered:
		win_zone_triggered = true
		$AudioStreamPlayer.play()
		body.zoom_in()
		emit_signal('win')
	
