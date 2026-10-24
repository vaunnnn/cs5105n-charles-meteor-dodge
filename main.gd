extends Node2D

@export_range(1, 2) var level_number: int = 1
@export var meteor_scene: PackedScene = preload("res://meteor.tscn")
@export var hunter_drone_scene: PackedScene

@onready var player: CharacterBody2D = $Player
@onready var spawn_timer: Timer = $SpawnTimer
@onready var survival_timer: Timer = $SurvivalTimer
@onready var arena: TileMapLayer = $Arena
@onready var hud = $HUD
@onready var countdown: Label = hud.countdown
@onready var message: Label = hud.message
@onready var goal: Area2D = $Exit

var game_over := false
var exit_open := false
var finished := false
var transitioning := false
var survival_seconds: float = 0.0
var score: int = 0
var drone_spawn_timer: Timer
var hunter_drone: HunterDrone


func _ready() -> void:
	AudioManager.start_music()
	player.position = Vector2(480, 528)
	spawn_timer.wait_time = 1.5 if level_number == 1 else 0.8
	survival_timer.wait_time = 20.0 if level_number == 1 else 30.0
	hud.restart_requested.connect(_request_restart)
	hud.main_menu_requested.connect(_request_main_menu)
	hud.objective.text = ("LEVEL 1 - METEOR TRAINING\nSurvive for 20 seconds."
		if level_number == 1 else "LEVEL 2 - METEOR STORM\nSurvive for 30 seconds.")
	goal.body_entered.connect(_on_exit_entered)
	spawn_timer.timeout.connect(_spawn_meteor)
	survival_timer.timeout.connect(_unlock_exit)
	spawn_timer.start()
	survival_timer.start()
	if level_number == 2 and hunter_drone_scene != null:
		drone_spawn_timer = Timer.new()
		drone_spawn_timer.one_shot = true
		add_child(drone_spawn_timer)
		drone_spawn_timer.timeout.connect(_spawn_hunter_drone)
		drone_spawn_timer.start(3.0)


func _process(delta: float) -> void:
	if not game_over and not finished and not transitioning:
		survival_seconds += delta
		# Award ten points for each complete second of this level attempt.
		score = floori(survival_seconds) * 10
		hud.update_stats(score, survival_seconds)
	if not game_over and not exit_open and not finished:
		countdown.text = "Time remaining: %d s" % ceili(survival_timer.time_left)
	# Respect keyboard focus: Enter on MAIN MENU must not also restart.
	if (game_over or finished) and not transitioning and Input.is_action_just_pressed("ui_accept") \
			and get_viewport().gui_get_focus_owner() == hud.get_node("%Restart"):
		_request_restart()


func _request_restart() -> void:
	if transitioning or not (game_over or finished):
		return
	transitioning = true
	_stop_hazards()
	AudioManager.play_click()
	_restart.call_deferred()


func _request_main_menu() -> void:
	if transitioning:
		return
	transitioning = true
	_stop_hazards()
	AudioManager.play_click()
	_load_main_menu.call_deferred()


func _load_main_menu() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _physics_process(_delta: float) -> void:
	if game_over or finished or transitioning:
		return
	# Check both ship edges against the hazard tiles' gameplay metadata.
	for offset in [-10.0, 0.0, 10.0]:
		var cell := arena.local_to_map(arena.to_local(player.global_position + Vector2(offset, 0)))
		var tile := arena.get_cell_tile_data(cell)
		if tile != null and tile.get_custom_data("hazard"):
			_on_player_hit()
			return


func _spawn_meteor() -> void:
	if game_over or exit_open or finished:
		return
	var meteor = meteor_scene.instantiate()
	# Cover the full movement lane so parking at an edge cannot bypass dodging.
	meteor.position = Vector2(randf_range(54.0, 906.0), 144.0)
	meteor.fall_speed = 260.0 if level_number == 1 else 310.0
	meteor.hit_player.connect(_on_player_hit)
	$Meteors.add_child(meteor)


func _stop_hazards() -> void:
	spawn_timer.stop()
	survival_timer.stop()
	if is_instance_valid(drone_spawn_timer):
		drone_spawn_timer.stop()
	if is_instance_valid(hunter_drone):
		hunter_drone.stop()
	for meteor in $Meteors.get_children():
		meteor.set_process(false)
		meteor.queue_free()


func _spawn_hunter_drone() -> void:
	if level_number != 2 or hunter_drone_scene == null or is_instance_valid(hunter_drone) \
			or game_over or exit_open or finished or transitioning:
		return
	hunter_drone = hunter_drone_scene.instantiate()
	hunter_drone.position = Vector2(240, 260)
	hunter_drone.z_index = 2
	hunter_drone.hit_player.connect(_on_player_hit)
	add_child(hunter_drone)


func _on_player_hit() -> void:
	if game_over or finished or transitioning:
		return
	game_over = true
	AudioManager.play_collision()
	_stop_hazards()
	player.set_physics_process(false)
	countdown.text = "Mission stopped"
	hud.show_result(score, survival_seconds)


func _unlock_exit() -> void:
	if game_over or finished:
		return
	exit_open = true
	_stop_hazards()
	$Exit/Marker.color = Color("5bffc1")
	$Exit/Label.text = "EXIT\nOPEN >"
	countdown.text = "Survived! Move right to the green EXIT >"
	for body in goal.get_overlapping_bodies():
		_on_exit_entered(body)


func _on_exit_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not exit_open or game_over or finished or transitioning:
		return
	player.set_physics_process(false)
	if level_number == 1:
		transitioning = true
		_load_second_level.call_deferred()
	else:
		finished = true
		hud.show_result(score, survival_seconds, true)


func _load_second_level() -> void:
	get_tree().change_scene_to_file("res://level_2.tscn")


func _restart() -> void:
	if finished:
		get_tree().change_scene_to_file("res://level_1.tscn")
	else:
		get_tree().reload_current_scene()
