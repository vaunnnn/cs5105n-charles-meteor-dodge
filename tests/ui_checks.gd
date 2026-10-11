extends SceneTree

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func frames() -> void:
	for index in range(4):
		await process_frame
		await physics_frame

func check(condition: bool, description: String) -> void:
	print(("PASS: " if condition else "FAIL: ") + description)
	if not condition:
		failures += 1

func click(button: Button) -> void:
	await frames()
	var location := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = location
	root.push_input(motion, true)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = location
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
	await frames()

func run() -> void:
	root.size = Vector2i(960, 640)
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://ui/main_menu.tscn", "Project starts at menu")
	change_scene_to_file("res://ui/main_menu.tscn")
	await frames()
	check(root.gui_get_focus_owner() == current_scene.get_node("%Start"), "Start has keyboard focus")
	if "--quit-check" in OS.get_cmdline_user_args():
		# A successful Quit button closes this process; the watchdog fails otherwise.
		create_timer(3.0).timeout.connect(func() -> void:
			push_error("Quit button did not close the application")
			quit(1))
		await click(current_scene.get_node("%Quit"))
		return
	await click(current_scene.get_node("%Start"))
	var level = current_scene
	check(level.scene_file_path == "res://level_1.tscn", "Start mouse click loads playable Level 1")
	check(level.hud is CanvasLayer, "HUD uses CanvasLayer")
	level.spawn_timer.stop()
	var initial_time: float = level.survival_seconds
	await create_timer(0.2).timeout
	check(level.survival_seconds > initial_time, "Survival time advances during actual process frames")
	level.set_process(false)
	level.survival_seconds = 0.0
	level._process(0.6)
	level._process(0.65)
	check(level.score == 10 and is_equal_approx(level.survival_seconds, 1.25), "Delta accumulates time and awards ten points per whole second")
	check(not level.hud.get_node("%Overlay").visible, "Results hidden during play")
	check(level.hud.get_node("%Score").text == "SCORE  000010", "HUD shows current score")
	level._on_player_hit()
	level._process(5.0)
	check(level.score == 10 and is_equal_approx(level.survival_seconds, 1.25), "Death freezes score and survival time")
	check(level.hud.get_node("%Overlay").visible and level.hud.get_node("%FinalScore").text == "FINAL SCORE  000010", "Game Over displays final result")
	check(level.spawn_timer.is_stopped() and not level.player.is_physics_processing(), "Death stops spawning and movement")
	await click(level.hud.get_node("%Restart"))
	level = current_scene
	check(not level.game_over and level.score == 0 and level.survival_seconds < 1.0, "Restart mouse click resets attempt")
	level.spawn_timer.stop()
	level._on_player_hit()
	await click(level.hud.get_node("%MainMenu"))
	check(current_scene.scene_file_path == "res://ui/main_menu.tscn", "Main Menu mouse click returns to menu")
	await click(current_scene.get_node("%Start"))
	level = current_scene
	level.spawn_timer.stop()
	level._on_player_hit()
	level.hud.get_node("%MainMenu").grab_focus()
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_ENTER
		event.pressed = pressed
		root.push_input(event)
		await frames()
	check(current_scene.scene_file_path == "res://ui/main_menu.tscn", "Enter respects Main Menu button focus without restarting")
	print("UI checks complete: %d failure(s)" % failures)
	# Let the audio server release active playback before headless shutdown.
	for player in root.get_node("AudioManager").get_children():
		player.stop()
	await frames()
	quit(1 if failures else 0)
