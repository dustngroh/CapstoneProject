extends Node2D

@onready var player_name_label: Label = $PlayerNameLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_name(play_name: String):
	if player_name_label:
		player_name_label.text = play_name
