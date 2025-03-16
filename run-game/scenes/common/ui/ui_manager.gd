extends CanvasLayer

var login_screen = null
var create_account_screen = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LevelUI.visible = false # Hide level UI when loaded


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func show_login():
	hide_create_account()
	if login_screen == null:
		login_screen = load("res://scenes/common/ui/login_screen.tscn").instantiate()
		add_child(login_screen)
		login_screen.login_success.connect(_on_login_success)
		login_screen.go_to_create_account.connect(show_create_account)

func show_create_account():
	hide_login()
	if create_account_screen == null:
		create_account_screen = load("res://scenes/common/ui/create_account_screen.tscn").instantiate()
		add_child(create_account_screen)
		create_account_screen.account_created.connect(_on_account_created)
		create_account_screen.go_back_to_login.connect(show_login)

func _on_login_success(username):
	print("Logged in as:", username)
	hide_login()

func hide_login():
	if login_screen:
		login_screen.queue_free()
		login_screen = null

func hide_create_account():
	if create_account_screen:
		create_account_screen.queue_free()
		create_account_screen = null

func _on_account_created(username):
	print("Account created for:", username)
	hide_create_account()
	show_login()

func show_level_ui():
	$LevelUI.visible = true

func hide_level_ui():
	$LevelUI.visible = false
	$LevelUI/Leaderboard.visible = false
