extends Node2D

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var player: CharacterBody2D = get_tree().get_nodes_in_group("player")[-1]
var last_safe_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.is_on_floor():
		last_safe_position = player.global_position
	#if player.velocity.x < 1000: # if you want to keep the player moving right
		#player.velocity.x += 3


func _on_bottom_world_border_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Ensure it's the player
		body.position = last_safe_position + Vector2(0, -300)
