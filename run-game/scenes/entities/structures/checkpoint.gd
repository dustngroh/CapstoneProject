extends Area2D

@export var respawn_offset: Vector2 = Vector2.ZERO
var activated: bool = false
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if activated:
		return
	
	if body.is_in_group("player"):
		var game = get_tree().root.get_node("Game")
		if game and game.current_level:
			game.current_level.set_checkpoint(global_position + respawn_offset)
			activated = true
			$ReachedSound.play()
			visual_feedback()

func visual_feedback():
	if sprite:
		var tween = create_tween()

		# Flash green
		sprite.modulate = Color(0, 1, 0)

		# Reset rotation first in case it was rotated before
		sprite.rotation_degrees = 0

		# Spin + slight pop
		tween.tween_property(sprite, "rotation_degrees", 360, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(sprite, "scale", sprite.scale * 1.3, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_interval(0.1)
		tween.tween_property(sprite, "scale", sprite.scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
