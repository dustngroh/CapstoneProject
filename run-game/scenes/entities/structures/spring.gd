extends StaticBody2D

@export var bounce_force: float = -1500.0
@onready var spring_sprite = $AnimatedSprite2D

func _on_bounce_pad_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Make sure it's the player
		var player = body as CharacterBody2D
		player.velocity.y = bounce_force

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Make sure it's the player
		var player = body as CharacterBody2D
		$BoingSound.play()
		player.velocity.y = bounce_force
		player.zoom_out_effect()
		spring_sprite.play()
		
