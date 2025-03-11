extends Node

var music_player: AudioStreamPlayer

var is_muted : bool = false

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

# Function to play a specific song
func play_music(song_path: String):
	var new_song = load(song_path)  # Load the music file
	if new_song:
		music_player.stream = new_song 
		music_player.stream.loop = true
		update_music()  # Ensure the music starts or stops based on the mute state

# Function to stop the music
func stop_music():
	music_player.stop()

# Function to toggle mute state
func toggle_mute():
	is_muted = !is_muted
	update_music()
	
# Function to update music based on mute state
func update_music():
	if is_muted:
		music_player.stop()  # Stop music if muted
	else:
		music_player.play()  # Play music if not muted
