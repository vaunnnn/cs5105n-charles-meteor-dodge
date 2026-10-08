extends CharacterBody2D

@export var speed: float = 380.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var movement_trail: CPUParticles2D = $MovementTrail


func _ready() -> void:
	add_to_group("player")
	animation_player.play("idle")


func _physics_process(delta: float) -> void:
	var previous_x := global_position.x
	var direction = Input.get_axis("move_left", "move_right")

	velocity.x = direction * speed
	velocity.y = 0

	move_and_slide()

	var screen_width = get_viewport_rect().size.x

	position.x = clamp(
		position.x,
		54.0,
		screen_width - 54.0
	)

	# Emit only while moving; world-space particles stay behind the ship.
	var horizontal_travel := global_position.x - previous_x
	movement_trail.emitting = not is_zero_approx(horizontal_travel)
	if movement_trail.emitting:
		var trail_direction := -signf(horizontal_travel)
		movement_trail.position = Vector2(trail_direction * 20.0, 6.0)
		movement_trail.direction = Vector2(trail_direction, 0.0)

	# Keep directional tilt separate from AnimationPlayer's scale tracks.
	var target_rotation = direction * 0.12
	sprite.rotation = lerp(
		sprite.rotation,
		target_rotation,
		10.0 * delta
	)

	var animation_name: StringName = &"move" if direction != 0 else &"idle"
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)


func _process(_delta: float) -> void:
	# Level logic disables physics on game over or completion.
	if not is_physics_processing():
		movement_trail.emitting = false
