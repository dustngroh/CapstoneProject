extends Node

signal start_level(level_number: int)
signal all_players_ready
signal level_complete(scoreboard: Array)
signal player_position_updated(player_id, play_name, x, y)
signal lobby_created
signal lobby_joined
signal player_joined(total_players: int)
signal player_list_update(player_count, player_names, action, player_name)
signal connected_users(user_count)
signal connection_successful
signal connection_failed
signal new_host

@export var websocket_url = "wss://run-game.xyz:8080" 

var socket : WebSocketPeer
var lobby_id : String = ""
var player_name : String = ""
var json = JSON.new()
var connected = false
var is_host = false

# Connects to the WebSocket server when the player selects multiplayer
func connect_to_server(name: String):
	player_name = name
	socket = WebSocketPeer.new()
	
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect to WebSocket server")
		connection_failed.emit()
		return
	
	print("Connecting to WebSocket server...")
	#connected = true
	#connection_successful.emit()
	set_process(true)

func disconnect_from_server():
	if socket and connected:
		socket.close()
		connected = false
		is_host = false
		set_process(false)
		print("Disconnected from WebSocket server")

func _ready():
	set_process(false)

func _process(_delta):
	#if not connected:
	#	return

	socket.poll()
	var state = socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		if not connected:  # Only emit success once when the socket is open
			print("WebSocket connection established.")
			connected = true
			connection_successful.emit()
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet().get_string_from_utf8()
			handle_server_message(packet)

	elif state == WebSocketPeer.STATE_CLOSED:
		print("WebSocket closed")
		connected = false
		set_process(false)

func handle_server_message(message: String):
	var error = json.parse(message)
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", message)
		return

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		print("Unexpected data: ", data)
		return

	match data.get("type", ""):
		"lobby_created":
			lobby_id = data["lobbyId"]
			is_host = true
			lobby_created.emit()
			print("Lobby created with ID: ", lobby_id)

		"lobby_joined":
			lobby_id = data["lobbyId"]
			lobby_joined.emit()
			print("Joined lobby: ", lobby_id)

		"player_joined":
			player_joined.emit(data["playerCount"])
			print("A player joined. Total players: ", data["playerCount"])

		"player_list_update":
			player_list_update.emit(data.playerCount, data.players, data.action, data.player)

		"connected_users":
			connected_users.emit(data.count)

		"new_host":
			new_host.emit()

		"start_game":
			print("Game has started!")
			start_level.emit(data["level_number"])

		"all_ready":
			print("All players are ready!")
			all_players_ready.emit()

		"player_position":
			player_position_updated.emit(data["id"], data["name"], data["x"], data["y"])

		"player_finished":
			print("Player finished. Finished: ", data["finishedCount"], " / ", data["totalPlayers"])

		"scoreboard":
			level_complete.emit(data["results"])
			print("Final Scoreboard:")
			for result in data["results"]:
				print("%d. %s - %.2f seconds" % [result["rank"], result["name"], result["time"]])

		"error":
			print("Error from server: ", data["message"])

func send_message(data: Dictionary):
	if not connected:
		print("Not connected to WebSocket server")
		return
	
	var json_str = json.stringify(data)
	socket.send_text(json_str)

func create_lobby():
	send_message({ "type": "create_lobby", "name": player_name })

func find_or_create_lobby():
	send_message({ "type": "find_or_create_lobby", "name": player_name })

func join_lobby(lobby_id: String):
	send_message({ "type": "join_lobby", "lobbyId": lobby_id, "name": player_name })

func start_game(level_number: int):
	send_message({ "type": "start_game", "level_number": level_number })

func mark_ready():
	send_message({ "type": "player_ready" })

func send_player_finish(time: float):
	send_message({ "type": "player_finished", "time": time })
