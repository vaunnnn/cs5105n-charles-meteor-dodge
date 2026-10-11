extends Control

var transitioning := false

func _ready() -> void:
	AudioManager.stop_music()
	Settings.large_text_changed.connect(_apply_text_sizes)
	%LargeText.set_pressed_no_signal(Settings.large_text)
	%LargeText.toggled.connect(_on_large_text_toggled)
	_apply_text_sizes()
	%Start.pressed.connect(_start_game)
	%Quit.pressed.connect(_quit_game)
	%Start.grab_focus()

func _start_game() -> void:
	if transitioning:
		return
	transitioning = true
	AudioManager.play_click()
	var error := get_tree().change_scene_to_file("res://level_1.tscn")
	if error != OK:
		transitioning = false
		push_error("Unable to load Level 1: %s" % error_string(error))

func _apply_text_sizes() -> void:
	Settings.apply_text_sizes(self)

func _on_large_text_toggled(enabled: bool) -> void:
	AudioManager.play_click()
	Settings.set_large_text(enabled)

func _quit_game() -> void:
	if transitioning:
		return
	transitioning = true
	%Start.disabled = true
	%Quit.disabled = true
	%LargeText.disabled = true
	AudioManager.play_click()
	# Give the final click time to finish before closing the application.
	await get_tree().create_timer(AudioManager.click.stream.get_length() + 0.05).timeout
	get_tree().quit()
