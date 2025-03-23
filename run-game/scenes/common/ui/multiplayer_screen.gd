extends Control

var base_level_path = "res://scenes/levels/multiplayer_levels/multiplayer_level_"

@onready var name_field = $VBoxContainer/NameField
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var connect_button = $VBoxContainer/ConnectButton
@onready var find_lobby_button = $VBoxContainer/FindLobbyButton
@onready var start_button = $VBoxContainer/StartButton
@onready var lobby_info_label = $LobbyInfoLabel
@onready var level_number_label = $VBoxContainer/LevelNumberLabel
@onready var level_number_box = $VBoxContainer/LevelNumberBox
@onready var player_list_label = $PlayerListLabel
@onready var connected_users_label = $ConnectedUsersLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WebSocketManager.start_level.connect(start_game)
	WebSocketManager.lobby_created.connect(_on_lobby_created)
	WebSocketManager.lobby_joined.connect(_on_lobby_joined)
	WebSocketManager.player_joined.connect(_on_player_joined)
	WebSocketManager.connection_successful.connect(_on_successful_connection)
	WebSocketManager.connection_failed.connect(_on_failed_connection)
	WebSocketManager.player_list_update.connect(_on_player_list_updated)
	WebSocketManager.connected_users.connect(_on_connected_users_received)
	WebSocketManager.new_host.connect(_on_new_host)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_connect_button_pressed() -> void:
	var name = name_field.text
	if name.is_empty():
		error_label.text = "Please enter a name."
		return
	
	error_label.text = ""
	lobby_info_label.text = "Attempting Connection..."
	WebSocketManager.connect_to_server(name)
	


func _on_find_lobby_button_pressed() -> void:
	WebSocketManager.find_or_create_lobby()
	

func start_game(level_number: int) -> void:
	MusicManager.play_music("res://assets/audio/music/Crowander - Racing Ladybird.mp3")
	var current_level_path = base_level_path + str(level_number) + ".tscn"
	var game = get_tree().root.get_node_or_null("Game")
	if game:
		game.load_level(current_level_path)

func _on_lobby_created():
	lobby_info_label.text = "Lobby Created. Wait for players to join."
	level_number_label.visible = true
	level_number_box.visible = true
	start_button.visible = true
	find_lobby_button.disabled = true
	player_list_label.text = "Players:\n" + WebSocketManager.player_name

func _on_lobby_joined():
	lobby_info_label.text = "Lobby joined. Wait for host to start."
	find_lobby_button.disabled = true

func _on_start_button_pressed() -> void:
	var level_number = level_number_box.value
	WebSocketManager.start_game(level_number)

func _on_player_joined(total_players: int):
	lobby_info_label.text = "Player joined. Total players: " + str(total_players)

func _on_player_list_updated(player_count, player_names, action, player_name):
	# Check if a player joined or left
	if action == "joined":
		lobby_info_label.text = player_name + " joined. Total players: " + str(player_count)
	else:
		lobby_info_label.text = player_name + " left. Total players: " + str(player_count)
	
	# Update the list of player names
	var players = "\n".join(player_names)
	player_list_label.text = "Players:\n" + players

func _on_connected_users_received(user_count):
	connected_users_label.text = "Users Online: " + str(user_count)

func _on_new_host():
	level_number_label.visible = true
	level_number_box.visible = true
	start_button.visible = true

func _on_successful_connection():
	lobby_info_label.text = "Successfully Connected."
	find_lobby_button.visible = true
	connect_button.disabled = true
	name_field.editable = false

func _on_failed_connection():
	lobby_info_label.text = "Could not connect to server."


func _on_main_menu_button_pressed() -> void:
	WebSocketManager.disconnect_from_server()
	MusicManager.play_music("res://assets/audio/music/Lite Saturation - Calm.mp3")
	var game = get_tree().root.get_node("Game")
	if game:
		game.load_level("res://scenes/main/MainMenu.tscn")
