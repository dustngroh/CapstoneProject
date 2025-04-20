extends Area2D

@export var speed_boost_factor = 1.5
@export var speed_boost_duration = 3.0
@export var respawn_time = 5.0
@onready var respawn_timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	respawn_timer.wait_time = respawn_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.increase_speed(speed_boost_factor, speed_boost_duration)
		#queue_free()  # Remove the item after collection
		visible = false
		set_deferred("monitoring", false)
		respawn_timer.start()


func _on_timer_timeout() -> void:
	visible = true
	monitoring = true
