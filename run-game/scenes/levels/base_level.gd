extends Node2D

@export var player_scene: PackedScene

var player: CharacterBody2D
var elapsed_time: float = 0.0  # Time starts at 0
var timer_running: bool = true

@onready var level_timer: Timer = $Timer
@onready var time_label: Label = $UI/TimeLabel
@onready var win_zone: Area2D = $WinZone
@onready var leaderboard: CanvasLayer = $UI/Leaderboard
@onready var spawn_point: Marker2D = $SpawnPoint


func _ready():
	spawn_player()
	
	# Set up Timer
	level_timer.wait_time = 1.0
	level_timer.one_shot = false
	level_timer.start()

	# Connect WinZone trigger
	win_zone.win.connect(_on_winzone_enter)

	# Hide leaderboard initially
	leaderboard.visible = false

func _process(delta):
	if timer_running:
		elapsed_time += delta
		update_timer_display()

func update_timer_display():
	time_label.text = "Time: %.2f" % elapsed_time  # Shows time in seconds with 2 decimals

func spawn_player():
	if player_scene:
		player = player_scene.instantiate()  # Create an instance of Player
		add_child(player)  # Add to the scene
		player.global_position = spawn_point.global_position  # Move to SpawnPoint

func _on_winzone_enter():
	stop_timer()
	show_leaderboard()

func stop_timer():
	timer_running = false
	level_timer.stop()
	print("Final time: %.2f seconds" % elapsed_time)

func show_leaderboard():
	leaderboard.visible = true
	
	# Fetch leaderboard and display results
	#GameManager.current_level = name  # Store level name
	#GameManager.fetch_leaderboard(name)  # Fetch scores for this level
	
	await get_tree().create_timer(1.0).timeout  # Wait for API response
	#var scores = GameManager.level_scores.get(name, [])
	
	#var score_text = "\n".join(scores.map(func(s): return "%s - %.2f sec" % [s["player"], s["time"]]))
	$UI/Leaderboard/Label.text = "Top Scores:\n"
