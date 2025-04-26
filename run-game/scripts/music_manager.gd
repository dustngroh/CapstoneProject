extends Node

var music_player: AudioStreamPlayer

var is_muted : bool = false

var menu_songs = [
	"res://assets/audio/music/Lite Saturation - Calm.mp3",
	"res://assets/audio/music/chime_song_mellow_chill.mp3",
	"res://assets/audio/music/relaxing_ambient_melodies.mp3"
]

func _ready():
	if music_player == null:
		music_player = AudioStreamPlayer.new()
		music_player.bus = "music"
		add_child(music_player)
		#music_player.stream = load("res://assets/audio/music/Lite Saturation - Calm.mp3") # play default music
		play_random_menu_music()
		#music_player.stream.loop = true 
		#music_player.play() 


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

func play_random_menu_music():
	if menu_songs.size() > 0:
		var random_index = randi() % menu_songs.size()
		var selected_song = menu_songs[random_index]
		play_music(selected_song)

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
		music_player.stop()
	else:
		music_player.play()
