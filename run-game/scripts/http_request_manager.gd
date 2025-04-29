extends Node

var http_request : HTTPRequest
var base_url : String = "https://run-game-back-end.onrender.com"
var jwt_token : String = ""
var username : String = ""
var logged_in = false

signal login_success(user)
signal register_success(user)
signal login_failed(error)
signal register_failed(error)
signal score_submission_result(message: String)
signal personal_record_achieved(message: String)
signal world_record_achieved(message: String)
signal leaderboard_received(level: int, scores: Array)
signal replay_received(replay_data: Array)
signal endless_distance_submitted()
signal endless_leaderboard_received(scores: Array)



func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(_on_request_completed)
	
	# Check for jwt on startup
	validate_token()

# Login function
func login(username: String, password: String):
	var url = base_url + "/auth/login"
	var headers = ["Content-Type: application/json"]
	var body = {"username": username, "password": password}
	
	var json_body = JSON.stringify(body)
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

# Register function
func register(username: String, password: String):
	var url = base_url + "/auth/register"
	var headers = ["Content-Type: application/json"]
	var body = {"username": username, "password": password}
	
	var json_body = JSON.stringify(body)
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

# Validate jwt function
func validate_token():
	var jwt = JavaScriptBridge.eval("localStorage.getItem('jwt');", true)
	
	if jwt == null or jwt == "":
		print("No JWT found.")
		#login_failed.emit("No saved login session.")
		return
	
	jwt_token = jwt
	
	var url = base_url + "/auth/validate-token"
	var headers = ["Authorization: " + jwt]

	http_request.request(url, headers, HTTPClient.METHOD_GET)

func clear_token():
	jwt_token = ""
	JavaScriptBridge.eval("localStorage.removeItem('jwt');")
	username = ""
	logged_in = false

func is_logged_in():
	return logged_in

# Score submission
func submit_time(level_number: int, completion_time: float) -> void:
	if !logged_in:
		print("Not logged in — cannot submit score.")
		return

	# Convert to centiseconds (integer, 2 decimal precision)
	var centiseconds = int(round(completion_time * 100.0))

	var url = base_url + "/scores"
	var headers = [
		"Content-Type: application/json",
		"Authorization: " + jwt_token
	]
	var body = {
		"level_number": level_number,
		"completion_time": centiseconds
	}

	var json_body = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

func submit_time_with_replay(level_number: int, completion_time: float, replay_array: Array) -> void:
	if !logged_in:
		print("Not logged in — cannot submit score.")
		return

	var centiseconds = int(round(completion_time * 100.0))

	# Convert Vector2 positions to {x, y} dictionaries
	var replay_json_array = []
	for pos in replay_array:
		replay_json_array.append({ 
			"x": snapped(pos.x, 0.001),
			"y": snapped(pos.y, 0.001)
			 })

	# Stringify the whole replay array to send as a single JSON string
	var replay_json_string = JSON.stringify(replay_json_array)

	var url = base_url + "/scores"
	#var url = "http://localhost:3000" + "/scores"
	var headers = [
		"Content-Type: application/json",
		"Authorization: " + jwt_token
	]
	var body = {
		"level_number": level_number,
		"completion_time": centiseconds,
		"replay_data": replay_json_string
	}

	var json_body = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)


# Score retrieval
func fetch_leaderboard(level_number: int):
	var url = base_url + "/scores/" + str(level_number)
	http_request.request(url, [], HTTPClient.METHOD_GET)


func fetch_replay(level_number: int, username: String) -> void:
	var url = base_url + "/scores/replay/" + str(level_number) + "/" + username
	http_request.request(url, [], HTTPClient.METHOD_GET)

# Endless mode: Submit distance
func submit_endless_distance(distance: int) -> void:
	if !logged_in:
		print("Not logged in — cannot submit endless distance.")
		return

	var url = base_url + "/endless"
	var headers = [
		"Content-Type: application/json",
		"Authorization: " + jwt_token
	]
	var body = {
		"distance": distance
	}

	var json_body = JSON.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)

# Endless mode: Fetch leaderboard
func fetch_endless_leaderboard() -> void:
	var url = base_url + "/endless"
	http_request.request(url, [], HTTPClient.METHOD_GET)


func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("HTTP request failed with result code: %d" % result)
		return
	
	var body_text = body.get_string_from_utf8()
	var json = JSON.new()
	var error_code = json.parse(body_text)

	if error_code != OK:
		print("JSON parse failed: %s" % body_text)
		return

	var response = json.get_data()
	var response_type = response.get("type", "")
	
	match response_type:
				"login":
					if response_code == 200:
						jwt_token = response["token"]
						JavaScriptBridge.eval("localStorage.setItem('jwt', '" + jwt_token + "');")
						print("Login successful! Token saved.")
						logged_in = true
						username = response["username"]
						login_success.emit(response["username"])
					else:
						print("Login failed.")
						login_failed.emit(response["message"])

				"register":
					if response_code == 201:
						print("Registration successful: %s" % response["message"])
						register_success.emit(response["username"])
					else:
						print("Register failed.")
						register_failed.emit(response["message"])

				"validate-token":
					if response_code == 200 and response.get("valid", false):
						print("Token is valid. Welcome back, ", response["username"])
						logged_in = true
						username = response["username"]
						login_success.emit(response["username"])
					else:
						print("JWT is invalid or expired. Clearing it.")
						JavaScriptBridge.eval("localStorage.removeItem('jwt');")
						#login_failed.emit("Session expired or invalid.")

				"submit-score":
					if response_code == 200 or response_code == 201:
						#print("Score submission: %s" % response["message"])
						#emit_signal("score_submission_result", response["message"])
						var message = response["message"]
						var personal_record = response.get("personalRecord", false)
						var world_record = response.get("worldRecord", false)
						
						print("Score submission: %s" % message)
						
						if world_record:
							emit_signal("world_record_achieved", message)
						elif personal_record:
							emit_signal("personal_record_achieved", message)
						else:
							emit_signal("score_submission_result", message)
					else:
						print("Score submission failed: %s" % response.get("message", "Unknown error"))
						emit_signal("score_submission_result", "Submission failed.")

				"get-leaderboard":
					if response_code == 200:
						print("Top scores for level %d:" % response["level"])
						emit_signal("leaderboard_received", response["level"], response["scores"])
						for score in response["scores"]:
							var time = float(score["completion_time"]) / 100.0
							print("- %s: %.2f seconds at %s" % [score["username"], time, score["timestamp"]])
					else:
						print("Failed to retrieve leaderboard: %s" % response.get("message", "Unknown error"))

				"submit-distance":
					if response_code == 201:
						endless_distance_submitted.emit()
						print("Endless distance submitted successfully.")
					else:
						print("Failed to submit endless distance: %s" % response.get("message", "Unknown error"))

				"get-endless-leaderboard":
					if response_code == 200:
						endless_leaderboard_received.emit(response["scores"])
						
					else:
						print("Failed to retrieve endless leaderboard: %s" % response.get("message", "Unknown error"))

				"get-replay":
					if response_code == 200:
						var replay_array = response.get("replay_data", "[]")
						#var replay_array = JSON.parse_string(replay_string)
						print("Replay data received!")
						emit_signal("replay_received", replay_array)
					else:
						print("Failed to retrieve replay: %s" % response.get("message", "Unknown error"))

				"error":
					if response.has("message"):
						print("Error: %s" % response["message"])
					else:
						print("An error occurred without a message.")

				_:
					print("Unknown response type: %s" % response_type)
