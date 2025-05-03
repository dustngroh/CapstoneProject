extends Node2D

@onready var player_name_label: Label = $PlayerNameLabel


var replay_data: Array = []
var total_time: float = 1.0
var current_time: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_name(play_name: String):
	if player_name_label:
		player_name_label.text = play_name


func set_replay(data: Array, duration: float):
	replay_data = data
	total_time = duration
	current_time = 0.0

func update_position(time_elapsed: float):
	current_time = time_elapsed
	var index = int(clamp((replay_data.size() - 1) * (current_time / total_time), 0, replay_data.size() - 1))
	var pos_data = replay_data[index]
	global_position = Vector2(pos_data["x"], pos_data["y"])
