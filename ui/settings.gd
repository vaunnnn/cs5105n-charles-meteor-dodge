extends Node

signal large_text_changed

const SAVE_PATH := "user://settings.cfg"
var large_text := false

func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		large_text = bool(config.get_value("accessibility", "large_text", false))

func set_large_text(enabled: bool) -> void:
	if large_text == enabled:
		return
	large_text = enabled
	large_text_changed.emit()
	var config := ConfigFile.new()
	config.set_value("accessibility", "large_text", large_text)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("Could not save Large Text preference: %s" % error_string(error))

func apply_text_sizes(node: Node) -> void:
	# Cache authored sizes so toggling never compounds the scale.
	if node is Label or node is Button:
		if not node.has_meta("normal_font_size"):
			node.set_meta("normal_font_size", node.get_theme_font_size("font_size"))
		var normal_size: int = node.get_meta("normal_font_size")
		node.add_theme_font_size_override("font_size", roundi(normal_size * (1.25 if large_text else 1.0)))
	for child in node.get_children():
		apply_text_sizes(child)
