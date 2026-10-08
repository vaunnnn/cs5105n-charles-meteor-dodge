extends CharacterBody2D

@export var speed: float = 380.0

@onready var sprite: Sprite2D = $Sprite2D

var base_scale: Vector2


func _ready() -> void:
	add_to_group("player")
	base_scale = sprite.scale


func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")

	velocity.x = direction * speed
	velocity.y = 0

	move_and_slide()

	var screen_width = get_viewport_rect().size.x

	position.x = clamp(
		position.x,
		30.0,
		screen_width - 30.0
	)

	# Game feel / juice
	var target_rotation = direction * 0.12
	sprite.rotation = lerp(
		sprite.rotation,
		target_rotation,
		10.0 * delta
	)

	var target_scale = base_scale

	if direction != 0:
		target_scale = base_scale * Vector2(1.08, 0.92)

	sprite.scale = sprite.scale.lerp(
		target_scale,
		10.0 * delta
	)
