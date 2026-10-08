extends SceneTree
# Structural and real-duration timer checks. Meteors are disabled only during
# countdown measurement; this is not an interactive difficulty playtest.

var failures := 0

func check(condition: bool, description: String) -> void:
	print(("PASS: " if condition else "FAIL: ") + description)
	if not condition:
		failures += 1

func frames() -> void:
	for index in range(4):
		await physics_frame
		await process_frame

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	seed(406)
	for number in [1, 2]:
		change_scene_to_file("res://level_%d.tscn" % number)
		await frames()
		var level = current_scene
		level.spawn_timer.stop()
		level.survival_timer.stop()
		var arena: TileMapLayer = level.arena
		var valid_cells := true
		for cell in arena.get_used_cells():
			if arena.get_cell_tile_data(cell) == null:
				valid_cells = false
		check(valid_cells and arena.get_used_cells().size() == 420, "Level %d: all 420 cells resolve to valid tiles" % number)
		check(arena.collision_enabled and arena.tile_set.get_physics_layer_collision_layer(0) == 1,
			"Level %d: TileMap physics enabled on player collision layer" % number)
		check(level.player.test_move(level.player.global_transform, Vector2(-600, 0)),
			"Level %d: actual left TileMap wall collision, independent of clamp" % number)
		check(level.player.test_move(level.player.global_transform, Vector2(600, 0)),
			"Level %d: actual right TileMap wall collision, independent of clamp" % number)
		check(not level.player.test_move(level.player.global_transform, Vector2(368, 0)),
			"Level %d: unobstructed horizontal route to exit" % number)
		var safe_route := true
		for x in range(470, 859):
			var tile := arena.get_cell_tile_data(arena.local_to_map(Vector2(x, 528)))
			if tile == null or tile.get_custom_data("hazard"):
				safe_route = false
		check(safe_route and level.goal.position.y == level.player.position.y,
			"Level %d: entire ship-to-exit route avoids hazard tiles" % number)
		check(level.goal.collision_mask & level.player.collision_layer != 0,
			"Level %d: goal detects player layer" % number)
		var minimum := 1000.0
		var maximum := 0.0
		for index in range(256):
			level._spawn_meteor()
			var meteor = level.get_node("Meteors").get_child(index)
			minimum = minf(minimum, meteor.position.x)
			maximum = maxf(maximum, meteor.position.x)
		check(minimum < 74.0 and maximum > 886.0,
			"Level %d: meteor coverage includes both former safe parking spots" % number)
		level._stop_hazards()
		await frames()
		if number == 2:
			level.player.position.x = 895
			await frames()
			check(level.game_over, "Right hazard kills when ship edge overlaps")
			change_scene_to_file("res://level_2.tscn")
			await frames()
			level = current_scene
			level.spawn_timer.stop()
			level.survival_timer.stop()
		var duration: float = 20.0 if number == 1 else 30.0
		var start := Time.get_ticks_msec()
		level.survival_timer.start(duration)
		await create_timer(duration - 0.25).timeout
		check(not level.exit_open and not level.game_over,
			"Level %d: exit stays locked until full survival duration" % number)
		await create_timer(0.4).timeout
		check(level.exit_open and level.spawn_timer.is_stopped()
			and Time.get_ticks_msec() - start >= duration * 1000,
			"Level %d: real %d-second countdown opens exit" % [number, int(duration)])
		if number == 2:
			# Separately exercise unlock while already touching the locked goal.
			change_scene_to_file("res://level_2.tscn")
			await frames()
			level = current_scene
			level.spawn_timer.stop()
			level.player.position = level.goal.position
			await frames()
			level.survival_timer.start(0.05)
			await create_timer(0.15).timeout
			check(level.finished, "Already overlapping final exit completes on unlock")
			level._on_exit_entered(level.player)
			check(level.finished and not level.transitioning, "Repeated goal signal cannot transition after victory")
	print("Level audit complete: %d failure(s)" % failures)
	quit(1 if failures else 0)
