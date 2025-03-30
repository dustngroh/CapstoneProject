extends Node

var http_request : HTTPRequest
var base_url : String = "https://run-game-back-end.onrender.com"
var jwt_token : String = "" 

signal login_success(user)
signal register_success(user)
signal login_failed(error)
signal register_failed(error)

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(_on_request_completed)

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


func _on_request_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	var response_type = response.get("type", "")
	
	match response_type:
				"login":
					if response_code == 200:
						jwt_token = response["token"]
						print("Login successful! Token saved.")
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
				"error":
					if response.has("message"):
						print("Error: %s" % response["message"])
					else:
						print("An error occurred without a message.")
				_:
					print("Unknown response type: %s" % response_type)
