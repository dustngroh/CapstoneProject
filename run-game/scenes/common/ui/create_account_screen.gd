extends Control

@onready var username_field = $VBoxContainer/UsernameField
@onready var password_field = $VBoxContainer/PasswordField
@onready var confirm_password_field = $VBoxContainer/ConfirmPasswordField
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var create_account_button = $VBoxContainer/CreateAccountButton
@onready var back_button = $VBoxContainer/BackButton
@onready var close_button = $CloseButton

signal account_created(username)
signal go_back_to_login

func _ready():
	create_account_button.pressed.connect(_on_create_account_pressed)
	back_button.pressed.connect(_on_back_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_create_account_pressed():
	var username = username_field.text
	var password = password_field.text
	var confirm_password = confirm_password_field.text

	if username.is_empty() or password.is_empty() or confirm_password.is_empty():
		error_label.text = "Fields cannot be empty."
		return
	
	if password != confirm_password:
		error_label.text = "Passwords do not match."
		return

	error_label.text = "Attempting to create account...\nThis may take a minute."
	HTTPRequestManager.register(username, password)

func _on_back_pressed():
	go_back_to_login.emit()
	
func _on_close_pressed():
	UIManager.hide_create_account()

func set_error_label(text):
	error_label.text = text
