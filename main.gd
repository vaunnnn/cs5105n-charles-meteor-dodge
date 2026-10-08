extends Node2D

@export var meteor_scene: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer
@onready var player: CharacterBody2D = $Player
@onready var game_over_label: Label = $GameOverLabel

var game_over: bool = false


func _ready() -> void:
	spawn_timer.timeout.connect(_spawn_meteor)
	game_over_label.visible = false


func _process(_delta: float) -> void:
	if game_over and Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()


func _spawn_meteor() -> void:
	if game_over:
		return

	if meteor_scene == null:
		return

	var meteor = meteor_scene.instantiate()

	add_child(meteor)

	var screen_width = get_viewport_rect().size.x

	meteor.position = Vector2(
		randf_range(40.0, screen_width - 40.0),
		-50.0
	)

	meteor.hit_player.connect(_on_player_hit)


func _on_player_hit() -> void:
	if game_over:
		return

	game_over = true

	spawn_timer.stop()
	player.set_physics_process(false)

	game_over_label.visible = true
