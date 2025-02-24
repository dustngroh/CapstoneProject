extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_win_zone_win() -> void:
	$ResultsScreen.show_results("res://scenes/levels/test_levels/test_level.tscn")
