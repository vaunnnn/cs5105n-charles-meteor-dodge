class_name HunterDrone
extends CharacterBody2D

signal hit_player

enum State { PATROL, CHASE, ATTACK }

@export var patrol_speed: float = 60.0
@export var chase_speed: float = 120.0
@export var detection_radius: float = 250.0
@export var detection_release_radius: float = 290.0
@export var attack_radius: float = 35.0
@export var attack_release_radius: float = 45.0
@export var attack_cooldown: float = 1.0
@export var attack_windup: float = 0.45
# These are arena-local positions, independent of the drone's spawn position.
@export var patrol_positions := PackedVector2Array([
	Vector2(240, 320), Vector2(300, 320), Vector2(300, 260),
	Vector2(660, 260), Vector2(660, 320), Vector2(720, 320),
	Vector2(660, 320), Vector2(660, 260), Vector2(300, 260), Vector2(300, 320)])
@export var arena_bounds := Rect2(48, 176, 864, 352)

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

var state: State = State.PATROL
var active := true
var target_player: Node2D
var patrol_index := 0
var attack_elapsed := 0.0
var cooldown_remaining := 0.0
var target_refresh_remaining := 0.0
var hit_reported := false


func _ready() -> void:
	# Instance-specific shapes keep radius tuning independent between drones.
	$DetectionArea/CollisionShape2D.shape = CircleShape2D.new()
	$DetectionArea/CollisionShape2D.shape.radius = detection_release_radius
	$AttackArea/CollisionShape2D.shape = CircleShape2D.new()
	$AttackArea/CollisionShape2D.shape.radius = attack_radius
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not active:
		return
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)
	_update_detection()
	match state:
		State.PATROL:
			_patrol(delta)
		State.CHASE:
			_chase(delta)
		State.ATTACK:
			_attack(delta)


func _update_detection() -> void:
	if is_instance_valid(target_player):
		# Wider release range prevents flickering at the acquisition boundary.
		if global_position.distance_to(target_player.global_position) > detection_release_radius:
			target_player = null
			_change_state(State.PATROL)
		return
	if state != State.PATROL:
		_change_state(State.PATROL)
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group("player") and global_position.distance_to(body.global_position) <= detection_radius:
			target_player = body
			_change_state(State.CHASE)
			return


func _patrol(delta: float) -> void:
	if patrol_positions.is_empty():
		velocity = Vector2.ZERO
		return
	var destination := _arena_point(patrol_positions[patrol_index])
	if global_position.distance_to(destination) <= 8.0:
		patrol_index = (patrol_index + 1) % patrol_positions.size()
		destination = _arena_point(patrol_positions[patrol_index])
	_follow_path(destination, patrol_speed, delta)


func _chase(delta: float) -> void:
	if not is_instance_valid(target_player):
		return
	if _player_in_attack_range():
		_change_state(State.ATTACK)
		velocity = Vector2.ZERO
		return
	_follow_path(target_player.global_position, chase_speed, delta)


func _attack(delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_instance_valid(target_player):
		return
	if global_position.distance_to(target_player.global_position) > attack_release_radius:
		_change_state(State.CHASE)
		return
	# A visible red windup gives the horizontally moving player time to evade.
	attack_elapsed += delta
	if attack_elapsed >= attack_windup and cooldown_remaining <= 0.0 and _player_in_attack_range() and not hit_reported:
		cooldown_remaining = attack_cooldown
		hit_reported = true
		hit_player.emit()


func _player_in_attack_range() -> bool:
	return is_instance_valid(target_player) and attack_area.overlaps_body(target_player) \
		and global_position.distance_to(target_player.global_position) <= attack_radius


func _change_state(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	attack_elapsed = 0.0
	target_refresh_remaining = 0.0
	queue_redraw()


func _arena_point(point: Vector2) -> Vector2:
	return get_parent().to_global(point.clamp(arena_bounds.position, arena_bounds.end))


func _follow_path(destination: Vector2, speed: float, delta: float) -> void:
	velocity = Vector2.ZERO
	var map := navigation_agent.get_navigation_map()
	# NavigationServer synchronizes after the scene enters the tree.
	if not map.is_valid() or not NavigationServer2D.map_is_active(map) \
			or NavigationServer2D.map_get_iteration_id(map) == 0:
		return
	target_refresh_remaining -= delta
	if target_refresh_remaining <= 0.0:
		navigation_agent.target_position = _arena_point(get_parent().to_local(destination))
		target_refresh_remaining = 0.2
	var next_position := navigation_agent.get_next_path_position()
	if navigation_agent.get_current_navigation_path().is_empty() or navigation_agent.is_navigation_finished():
		return
	# An unreachable target may still have a useful partial path; stop at its end.
	velocity = global_position.direction_to(next_position) * speed
	move_and_slide()
	position = position.clamp(arena_bounds.position, arena_bounds.end)


func stop() -> void:
	active = false
	velocity = Vector2.ZERO
	target_player = null
	set_physics_process(false)
	queue_redraw()


func _draw() -> void:
	var accent := Color("80e8ff")
	if state == State.CHASE:
		accent = Color("ffce65")
	elif state == State.ATTACK:
		accent = Color("ff5277")
	if not active:
		accent = Color("65758c")
	# Angular magenta wings and a bright sensor distinguish it from icon meteors.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-26, -10), Vector2(-10, -5), Vector2(0, -16),
		Vector2(10, -5), Vector2(26, -10), Vector2(20, 12),
		Vector2(0, 6), Vector2(-20, 12)]), Color("a552bb"))
	draw_circle(Vector2.ZERO, 12.0, Color("15243e"))
	draw_arc(Vector2.ZERO, 13.0, 0, TAU, 32, accent, 2.0)
	draw_circle(Vector2(0, 1), 5.0, accent)
	if state == State.ATTACK and active:
		draw_arc(Vector2.ZERO, attack_radius, 0, TAU, 40, accent, 1.5)
