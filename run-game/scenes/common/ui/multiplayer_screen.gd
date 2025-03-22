extends Control

var base_level_path = "res://scenes/levels/multiplayer_levels/multiplayer_level_"

@onready var name_field = $VBoxContainer/NameField
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var find_lobby_button = $VBoxContainer/FindLobbyButton
@onready var start_button = $VBoxContainer/StartButton
@onready var lobby_info_label = $LobbyInfoLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WebSocketManager.start_level.connect(start_game)
	WebSocketManager.lobby_created.connect(_on_lobby_created)
	WebSocketManager.lobby_joined.connect(_on_lobby_joined)
	WebSocketManager.player_joined.connect(_on_player_joined)
	WebSocketManager.connection_successful.connect(_on_successful_connection)
	WebSocketManager.connection_failed.connect(_on_failed_connection)


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
	#await get_tree().create_timer(1.0).timeout
	#WebSocketManager.check_connection()
	#find_lobby_button.visible = true


func _on_find_lobby_button_pressed() -> void:
	WebSocketManager.find_or_create_lobby()
	#WebSocketManager.start_game(1)
	

func start_game(level_number: int) -> void:
	var current_level_path = base_level_path + str(level_number) + ".tscn"
	var game = get_tree().root.get_node_or_null("Game")
	if game:
		game.load_level(current_level_path)

func _on_lobby_created():
	lobby_info_label.text = "Lobby Created. Wait for players to join."
	start_button.visible = true

func _on_lobby_joined():
	lobby_info_label.text = "Lobby joined. Wait for host to start."

func _on_start_button_pressed() -> void:
	WebSocketManager.start_game(1)

func _on_player_joined(total_players: int):
	lobby_info_label.text = "Player joined. Total players: " + str(total_players)

func _on_successful_connection():
	lobby_info_label.text = "Successfully Connected."
	find_lobby_button.visible = true

func _on_failed_connection():
	lobby_info_label.text = "Could not connect to server."


func _on_name_field_focus_entered() -> void:
	if OS.has_feature('JavaScript'):
		name_field.text = JavaScriptBridge.eval("""
			window.prompt('Username')
			""")
	
	release_focus()
