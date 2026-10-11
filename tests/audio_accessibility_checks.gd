extends SceneTree

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func frames() -> void:
	for index in range(5):
		await process_frame
		await physics_frame

func check(condition: bool, description: String) -> void:
	print(("PASS: " if condition else "FAIL: ") + description)
	if not condition:
		failures += 1

func check_bounds(node: Node) -> void:
	if node is Control and node.is_visible_in_tree() and (node is Label or node is Button):
		var bounds: Rect2 = node.get_global_rect()
		check(Rect2(Vector2.ZERO, Vector2(960, 640)).encloses(bounds), "%s stays inside viewport" % node.name)
		check(node.size.y >= node.get_minimum_size().y, "%s has enough text height" % node.name)
	for child in node.get_children():
		check_bounds(child)
	if node is BoxContainer:
		var previous: Control = null
		for child in node.get_children():
			if child is Control and child.is_visible_in_tree():
				if previous != null:
					check(not previous.get_global_rect().intersects(child.get_global_rect()), "%s children do not overlap" % node.name)
				previous = child

func run() -> void:
	root.size = Vector2i(960, 640)
	var settings = root.get_node("Settings")
	var audio = root.get_node("AudioManager")
	var original_setting: bool = settings.large_text
	for bus in ["Music", "SFX"]:
		var index := AudioServer.get_bus_index(bus)
		check(index > 0 and AudioServer.get_bus_send(index) == &"Master", bus + " routes to Master")
	var music_id: int = audio.music.get_instance_id()
	check(audio.music.bus == &"Music" and audio.click.bus == &"SFX" and audio.collision.bus == &"SFX", "Players route to dedicated buses")
	var music_bus := AudioServer.get_bus_index("Music")
	var sfx_bus := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(music_bus, true)
	check(not AudioServer.is_bus_mute(sfx_bus), "Muting Music leaves SFX independent")
	AudioServer.set_bus_mute(music_bus, false)
	check(AudioServer.get_bus_volume_db(music_bus) + audio.music.volume_db < AudioServer.get_bus_volume_db(sfx_bus) + audio.collision.volume_db, "Music gain is below collision gain")
	check(audio.music.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and audio.music.stream.loop_end == 352800, "Music loops over all 16 seconds")
	for player in [audio.music, audio.click, audio.collision]:
		check(player.stream is AudioStreamWAV and player.stream.get_length() > 0, "%s WAV imports" % player.name)
	settings.set_large_text(false)
	change_scene_to_file("res://ui/main_menu.tscn")
	await frames()
	var normal: int = current_scene.get_node("%Title").get_theme_font_size("font_size")
	current_scene.get_node("%LargeText").button_pressed = true
	await frames()
	check(settings.large_text and current_scene.get_node("%Title").get_theme_font_size("font_size") > normal, "Toggle enlarges menu")
	check_bounds(current_scene)
	var config := ConfigFile.new()
	check(config.load(settings.SAVE_PATH) == OK and config.get_value("accessibility", "large_text") == true, "Preference saved to disk")
	var fresh_settings = load("res://ui/settings.gd").new()
	root.add_child(fresh_settings)
	check(fresh_settings.large_text, "Fresh settings instance restores preference")
	fresh_settings.queue_free()
	current_scene.get_node("%Start").pressed.emit()
	check(audio.click.playing, "Start activation plays click")
	await scene_changed
	check(audio.click.playing, "Click survives Start scene transition")
	await frames()
	var level = current_scene
	level.spawn_timer.stop()
	check(audio.music.playing, "Music plays in gameplay")
	check(level.hud.get_node("%Score").get_theme_font_size("font_size") == 28, "Large Text persists into HUD")
	check_bounds(level.hud)
	level._unlock_exit()
	await frames()
	check_bounds(level.hud)
	level._on_player_hit()
	await frames()
	var position: float = audio.collision.get_playback_position()
	level._on_player_hit()
	check(audio.collision.playing and audio.collision.get_playback_position() >= position, "Repeated hit does not restart collision sound")
	check_bounds(level.hud)
	level._request_restart()
	await frames()
	level = current_scene
	level.spawn_timer.stop()
	check(audio.music.get_instance_id() == music_id and audio.get_child_count() == 3, "Restart retains one music player")
	check(level.hud.get_node("%Score").get_theme_font_size("font_size") == 28, "Large Text survives restart")
	level.hud.show_result(300, 30.0, true)
	await frames()
	check_bounds(level.hud)
	# Seek near the boundary to exercise wraparound without a full 16-second wait.
	audio.music.play(15.9)
	await create_timer(0.35).timeout
	check(audio.music.playing and audio.music.get_playback_position() < 1.0, "Music playback wraps at loop boundary")
	level._on_player_hit()
	level._request_main_menu()
	await frames()
	check(not audio.music.playing and audio.collision.playing, "Menu stops music while collision tail survives transition")
	check(current_scene.get_node("%LargeText").button_pressed, "Menu toggle remembers setting")
	current_scene.get_node("%LargeText").button_pressed = false
	await frames()
	check(current_scene.get_node("%Title").get_theme_font_size("font_size") == normal, "Toggle restores normal text without compounding")
	settings.set_large_text(original_setting)
	audio.click.stop()
	audio.collision.stop()
	await frames()
	print("Audio/accessibility checks complete: %d failure(s)" % failures)
	quit(1 if failures else 0)
