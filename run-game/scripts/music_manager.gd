extends Node

var music_player: AudioStreamPlayer

var is_muted : bool = false
var currently_playing: String = ""
var sfx_player: AudioStreamPlayer

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
	if sfx_player == null:
		sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "sfx"
		add_child(sfx_player)


# Function to play a specific song
func play_music(song_path: String):
	if song_path == currently_playing:
		print("Song is already playing.")
		return

	var new_song = load(song_path)
	if new_song == null:
		print("Failed to load song:", song_path)
		return

	music_player.stream = new_song
	music_player.stream.loop = true
	currently_playing = song_path
	update_music()
	
	#var new_song = load(song_path)  # Load the music file
	#if new_song:
		#music_player.stream = new_song 
		#music_player.stream.loop = true
		#update_music()  # Ensure the music starts or stops based on the mute state

func play_random_menu_music():
	if menu_songs.size() > 0:
		var random_index = randi() % menu_songs.size()
		var selected_song = menu_songs[random_index]
		play_music(selected_song)

# Function to stop the music
func stop_music():
	music_player.stop()
	currently_playing = ""

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

func play_personal_best_sound():
	var pb_sound = load("res://assets/audio/sounds/casino-bling.wav")
	if pb_sound:
		sfx_player.stream = pb_sound
		sfx_player.play()

func play_world_record_sound():
	var wr_sound = load("res://assets/audio/sounds/fanfare.wav")
	if wr_sound:
		sfx_player.stream = wr_sound
		sfx_player.play()

func play_falling_sound():
	var fall_sound = load("res://assets/audio/sounds/falling.wav")
	if fall_sound:
		sfx_player.stream = fall_sound
		sfx_player.play()
