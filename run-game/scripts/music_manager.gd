extends Node

var music_player: AudioStreamPlayer

func _ready():
	if music_player == null:
		music_player = AudioStreamPlayer.new()  # Create a new music player if it doesn't exist
		add_child(music_player)  # Add it to the scene tree
		music_player.stream = load("res://assets/audio/music/Lite Saturation - Calm.mp3") # play default music
		music_player.stream.loop = true 
		music_player.play() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
