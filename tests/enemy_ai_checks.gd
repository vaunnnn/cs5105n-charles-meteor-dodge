extends SceneTree

var failures := 0
var attacks := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	print(("PASS: " if condition else "FAIL: ") + description)
	if not condition:
		failures += 1

func frames(count: int = 5) -> void:
	for index in range(count):
		await physics_frame
		await process_frame

func load_level(number: int) -> Node:
	change_scene_to_file("res://level_%d.tscn" % number)
	await frames()
	var level = current_scene
	# Isolate AI from random meteors, preserving the real drone timer/navigation.
	level.spawn_timer.stop()
	return level

func place_drone(drone: HunterDrone, point: Vector2) -> void:
	drone.position = point
	drone.target_refresh_remaining = 0.0

func run() -> void:
	var level = await load_level(1)
	await create_timer(3.1).timeout
	check(level.hunter_drone_scene == null and level.drone_spawn_timer == null
		and not is_instance_valid(level.hunter_drone), "Level 1 has no drone or AI timer")
	check(level.survival_timer.wait_time == 20.0 and level.spawn_timer.wait_time == 1.5,
		"Level 1 keeps its original timing")
	level = await load_level(2)
	check(not is_instance_valid(level.hunter_drone), "Level 2 starts without a drone")
	await create_timer(2.6).timeout
	check(not is_instance_valid(level.hunter_drone), "Drone cannot spawn before the delay")
	await create_timer(0.5).timeout
	var drone: HunterDrone = level.hunter_drone
	check(is_instance_valid(drone), "Level 2 automatically spawns a drone after three seconds")
	if not is_instance_valid(drone):
		quit(1)
		return
	check(drone.state == HunterDrone.State.PATROL and not level.game_over,
		"Drone starts in PATROL safely away from the player")
	check(drone.position.distance_to(level.player.position) > drone.detection_radius,
		"Spawn gives the player space before detection")
	level._spawn_hunter_drone()
	check(level.hunter_drone == drone and drone.hit_player.get_connections().size() == 1,
		"Repeated spawn call keeps one drone and one game-over connection")
	var previous_position := drone.position
	await create_timer(0.3).timeout
	check(drone.position.distance_to(previous_position) > 5.0,
		"PATROL moves toward its waypoint through actual physics frames")
	check(not drone.navigation_agent.get_current_navigation_path().is_empty(),
		"NavigationAgent produces a real patrol path")
	place_drone(drone, drone.patrol_positions[0])
	await frames()
	check(drone.patrol_index == 1, "Reaching a patrol waypoint selects the next waypoint")
	var map := drone.navigation_agent.get_navigation_map()
	var path := NavigationServer2D.map_get_path(map, Vector2(240, 260), Vector2(848, 528), true)
	check(path.size() >= 2 and path[path.size() - 1].distance_to(Vector2(848, 528)) < 1.0,
		"Saved navigation region connects the upper arena to the player's lane")
	var bounds_valid := true
	for point in path:
		bounds_valid = bounds_valid and point.x >= 48 and point.x <= 912 and point.y >= 176 and point.y <= 528
	check(bounds_valid, "Navigation path stays within the existing walls")

	# Teleport only for setup; all detection and attacks use real Area2D overlaps.
	place_drone(drone, Vector2(480, 320))
	await frames()
	check(drone.state == HunterDrone.State.CHASE and drone.target_player == level.player,
		"Player detected by Area2D transitions PATROL to CHASE")
	var previous_distance := drone.position.distance_to(level.player.position)
	await create_timer(0.25).timeout
	check(drone.position.distance_to(level.player.position) < previous_distance,
		"CHASE follows the navigation path toward the player")
	level.player.position.x = 570
	await create_timer(0.25).timeout
	check(drone.navigation_agent.target_position.distance_to(level.player.global_position) < 1.0,
		"CHASE refreshes the moving player's navigation target")
	place_drone(drone, Vector2(570, 260))
	await frames()
	check(drone.state == HunterDrone.State.CHASE, "Detection hysteresis retains a player beyond acquisition range")
	level.player.position.x = 840
	await frames()
	check(drone.state == HunterDrone.State.PATROL and drone.target_player == null,
		"Escaping the release radius returns CHASE to PATROL")

	level.player.position.x = 480
	place_drone(drone, Vector2(480, 500))
	await frames()
	check(drone.state == HunterDrone.State.ATTACK and not level.game_over,
		"Attack area enters ATTACK with a fair windup")
	level.player.position.x = 540
	await frames()
	check(drone.state == HunterDrone.State.CHASE, "Leaving attack range returns ATTACK to CHASE")
	level.player.position.x = 480
	place_drone(drone, Vector2(480, 500))
	await frames()
	level.player.position.x = 840
	await frames()
	check(drone.state == HunterDrone.State.PATROL, "Escaping detection returns ATTACK to PATROL")
	level.player.position.x = 480
	place_drone(drone, Vector2(480, 500))
	drone.hit_player.connect(func() -> void: attacks += 1)
	await frames()
	await create_timer(0.6).timeout
	check(level.game_over and attacks == 1 and level.hud.get_node("%Overlay").visible,
		"Real attack signal invokes the existing game-over HUD exactly once")
	check(not drone.active and drone.velocity == Vector2.ZERO and not drone.is_physics_processing()
		and level.spawn_timer.is_stopped() and level.survival_timer.is_stopped(),
		"Game over stops drone motion, attacks, and existing timers")
	previous_position = drone.position
	await create_timer(1.1).timeout
	check(attacks == 1 and drone.position == previous_position, "Stopped drone cannot move or report another hit")
	var old_drone: WeakRef = weakref(drone)
	level._request_restart()
	await frames()
	level = current_scene
	level.spawn_timer.stop()
	check(old_drone.get_ref() == null and not is_instance_valid(level.hunter_drone),
		"Restart frees the old drone and resets the spawn delay")
	await create_timer(3.1).timeout
	drone = level.hunter_drone
	check(is_instance_valid(drone) and drone.hit_player.get_connections().size() == 1,
		"Restart creates a fresh drone with one game-over connection")
	level.survival_timer.start(0.05)
	await create_timer(0.15).timeout
	check(level.exit_open and not drone.active, "Timer expiry unlocks exit and stops the drone")
	previous_position = drone.position
	await frames()
	check(drone.position == previous_position, "Drone remains still while the exit is open")
	Input.action_press("move_right")
	await create_timer(1.0).timeout
	Input.action_release("move_right")
	await frames()
	check(level.finished and not level.game_over and not drone.active, "Level 2 remains completable through horizontal movement")

	level = await load_level(2)
	level.survival_timer.start(0.05)
	await create_timer(3.2).timeout
	check(level.exit_open and not is_instance_valid(level.hunter_drone), "Early unlock cancels a pending drone spawn")
	level = await load_level(2)
	level._on_player_hit()
	await create_timer(3.2).timeout
	check(not is_instance_valid(level.hunter_drone), "Early game over cancels a pending drone spawn")
	level = await load_level(2)
	level._spawn_hunter_drone()
	drone = level.hunter_drone
	# Test unavailable navigation with the real movement code: no straight-line fallback.
	await frames()
	var world_map: RID = level.get_world_2d().navigation_map
	NavigationServer2D.map_set_active(world_map, false)
	# NavigationServer changes are deferred until its next synchronization.
	await frames()
	previous_position = drone.position
	await frames()
	check(drone.position == previous_position and drone.velocity == Vector2.ZERO,
		"Inactive navigation map stops movement safely")
	NavigationServer2D.map_set_active(world_map, true)
	var empty_map := NavigationServer2D.map_create()
	NavigationServer2D.map_set_active(empty_map, true)
	drone.navigation_agent.set_navigation_map(empty_map)
	await frames()
	check(drone.navigation_agent.get_current_navigation_path().is_empty() and drone.velocity == Vector2.ZERO,
		"Empty navigation path is handled safely")
	drone.navigation_agent.set_navigation_map(level.get_world_2d().navigation_map)
	NavigationServer2D.free_rid(empty_map)
	level._request_main_menu()
	check(level.transitioning and not drone.active and level.drone_spawn_timer.is_stopped(),
		"Scene transition immediately stops the drone and spawn timer")
	await frames()
	check(current_scene.scene_file_path == "res://ui/main_menu.tscn", "Main menu transition still succeeds")
	await review_edge_cases()
	print("Enemy AI checks complete: %d failure(s)" % failures)
	for audio_player in root.get_node("AudioManager").get_children():
		audio_player.stop()
	await create_timer(0.25).timeout
	quit(1 if failures else 0)

func review_edge_cases() -> void:
	var level = await load_level(2)
	level._spawn_hunter_drone()
	var drone: HunterDrone = level.hunter_drone
	var decoy := CharacterBody2D.new()
	var decoy_shape := CollisionShape2D.new()
	decoy_shape.shape = CircleShape2D.new()
	decoy.add_child(decoy_shape)
	decoy.position = Vector2(300, 260)
	level.add_child(decoy)
	await frames()
	check(drone.detection_area.overlaps_body(decoy) and drone.state == HunterDrone.State.PATROL,
		"Detection ignores an overlapping layer-1 body outside the player group")
	decoy.queue_free()
	# Both overlap checks must exclude the drone, independently of group filtering.
	drone.set_physics_process(false)
	drone.position = level.goal.position
	level._spawn_meteor()
	var meteor = level.get_node("Meteors").get_child(0)
	meteor.position = drone.position
	meteor.fall_speed = 0.0
	await frames()
	check(not level.goal.overlaps_body(drone) and not meteor.overlaps_body(drone),
		"Exit and meteor masks exclude the drone's collision layer")
	check(is_instance_valid(meteor) and not level.game_over, "A meteor overlapping the drone does not report a player hit")
	meteor.position = level.player.position
	await frames()
	check(level.game_over and not drone.active and level.get_node("Meteors").get_child_count() == 0,
		"Actual meteor contact with the player stops the existing drone and clears meteors")

	level = await load_level(2)
	level._spawn_hunter_drone()
	drone = level.hunter_drone
	place_drone(drone, Vector2(480, 500))
	await frames()
	check(drone.state == HunterDrone.State.ATTACK, "Movement-escape scenario starts during the real attack windup")
	Input.action_press("move_right")
	await create_timer(0.2).timeout
	Input.action_release("move_right")
	await frames()
	check(not level.game_over and level.player.position.x > 540 and level.player.position.y == 528,
		"Horizontal player input can escape the windup without a hit")
	check(drone.state == HunterDrone.State.CHASE, "Escaping with movement input resumes pursuit")
	# A player in the hysteresis band must not be hit outside the true attack radius.
	level.player.position.x = 480
	place_drone(drone, Vector2(480, 500))
	await frames()
	level.player.position.x = 510
	await create_timer(0.6).timeout
	check(drone.state == HunterDrone.State.ATTACK and not level.game_over,
		"Attack hysteresis holds state without hitting a player outside 35 pixels")
	level.player.position.x = 540
	await frames()
	check(drone.state == HunterDrone.State.CHASE, "Leaving the attack release band resumes CHASE")
	level.player.position.x = 480
	place_drone(drone, Vector2(480, 500))
	await frames()
	check(drone.state == HunterDrone.State.ATTACK and drone.attack_elapsed < drone.attack_windup and not level.game_over,
		"Re-entering ATTACK resets the windup instead of immediately hitting")

	level = await load_level(2)
	level._spawn_hunter_drone()
	drone = level.hunter_drone
	place_drone(drone, Vector2(480, 320))
	await frames()
	check(drone.state == HunterDrone.State.CHASE, "Player-disappearance scenario first acquires a real target")
	# The main scene normally owns the player for its lifetime; isolate its tile check.
	level.set_physics_process(false)
	level.player.queue_free()
	await frames()
	check(drone.state == HunterDrone.State.PATROL and not is_instance_valid(drone.target_player),
		"A freed target safely returns the drone to PATROL")
