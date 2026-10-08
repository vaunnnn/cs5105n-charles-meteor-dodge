extends SceneTree

var failures := 0

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		push_error("FAIL: " + description)
		failures += 1

func frames(count: int = 4) -> void:
	for index in range(count):
		await physics_frame
		await process_frame

func load_level(number: int) -> Node:
	change_scene_to_file("res://level_%d.tscn" % number)
	await frames()
	return current_scene

func enter() -> void:
	Input.action_press("ui_accept")
	await frames()
	Input.action_release("ui_accept")
	await frames()

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var level = await load_level(1)
	check(level.arena.get_used_cells().size() == 420, "Level 1 has 420 saved tile cells")
	check(level.survival_timer.wait_time == 20.0 and level.spawn_timer.wait_time == 1.5, "Training timing")
	check(not level.exit_open, "Exit initially locked")
	level.spawn_timer.stop()
	level.player.position.x = 848
	await frames()
	check(current_scene == level and not level.finished, "Locked exit does not transition")
	level.player.position.x = 480
	level._spawn_meteor()
	var meteor = level.get_node("Meteors").get_child(0)
	check(meteor.fall_speed == 260.0, "Training meteor speed")
	meteor.position = level.player.position
	await frames()
	check(level.game_over and level.survival_timer.is_stopped() and level.spawn_timer.is_stopped(), "Actual meteor collision stops both timers")
	check(not level.player.is_physics_processing(), "Game over stops movement")
	await enter()
	level = current_scene
	check(level.level_number == 1 and not level.game_over, "Enter restarts Level 1")
	level.spawn_timer.stop()
	level.survival_timer.start(0.05)
	await create_timer(0.15).timeout
	check(level.exit_open and level.get_node("Meteors").get_child_count() == 0, "Timer expiry opens exit and clears meteors")
	Input.action_press("move_right")
	await create_timer(1.0).timeout
	Input.action_release("move_right")
	await frames()
	level = current_scene
	check(level.level_number == 2, "Horizontal movement reaches exit and transitions to Level 2")
	check(level.arena.get_used_cells().size() == 420, "Level 2 has 420 saved tile cells")
	check(level.survival_timer.wait_time == 30.0 and level.spawn_timer.wait_time == 0.8, "Storm timing")
	level.spawn_timer.stop()
	level._spawn_meteor()
	meteor = level.get_node("Meteors").get_child(0)
	check(meteor.fall_speed == 310.0, "Storm meteor speed")
	meteor.position.y = 800
	await frames()
	check(level.get_node("Meteors").get_child_count() == 0, "Offscreen meteor cleanup")
	level.player.position.x = 65
	await frames()
	check(level.game_over, "Striped hazard tile causes game over")
	await enter()
	level = current_scene
	check(level.level_number == 2 and not level.game_over, "Enter restarts current Level 2")
	level.spawn_timer.stop()
	level._spawn_meteor()
	level.get_node("Meteors").get_child(0).position = level.player.position
	await frames()
	check(level.game_over, "Level 2 meteor collision")
	await enter()
	level = current_scene
	level.spawn_timer.stop()
	level.survival_timer.start(0.05)
	await create_timer(0.15).timeout
	Input.action_press("move_right")
	await create_timer(1.0).timeout
	Input.action_release("move_right")
	await frames()
	check(level.finished and level.message.visible, "Horizontal movement reaches final exit and displays victory")
	await enter()
	level = current_scene
	check(level.level_number == 1 and not level.finished, "Victory Enter returns to Level 1")
	level.spawn_timer.stop()
	level.survival_timer.stop()
	Input.action_press("move_left")
	await create_timer(1.5).timeout
	Input.action_release("move_left")
	check(level.player.position.x >= 42, "Boundary blocks ship")
	print("Gameplay checks complete: %d failure(s)" % failures)
	quit(1 if failures else 0)
