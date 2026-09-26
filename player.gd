
extends Sprite2D

@export var speed: float = 350.0

func _process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")

	position.x += direction * speed * delta

	position.x = clampf(
		position.x,
		64.0,
		get_viewport_rect().size.x - 64.0
	)
