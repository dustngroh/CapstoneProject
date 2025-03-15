extends Control

@onready var username_field = $VBoxContainer/UsernameField
@onready var password_field = $VBoxContainer/PasswordField
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var login_button = $VBoxContainer/LoginButton
@onready var create_account_button = $VBoxContainer/CreateAccountButton
@onready var back_button = $VBoxContainer/BackButton
@onready var close_button = $CloseButton

signal login_success(username)
signal go_to_create_account

func _ready():
	login_button.pressed.connect(_on_login_pressed)
	create_account_button.pressed.connect(_on_create_account_pressed)
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_login_pressed():
	var username = username_field.text
	var password = password_field.text
	
	if username.is_empty() or password.is_empty():
		error_label.text = "Username and password cannot be empty."
		return
	
	# TODO: Replace with real authentication logic
	if username == "testuser" and password == "password123":
		error_label.text = ""
		login_success.emit(username)
		UIManager.hide_login()
	else:
		error_label.text = "Invalid username or password."

func _on_create_account_pressed():
	go_to_create_account.emit()
	
func _on_back_pressed():
	UIManager.hide_login()

func _on_close_pressed():
	UIManager.hide_login()
