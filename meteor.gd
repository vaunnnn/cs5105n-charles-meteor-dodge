extends Area2D

signal hit_player

@export var fall_speed: float = 260.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	position.y += fall_speed * delta

	if position.y > get_viewport_rect().size.y + 80:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		hit_player.emit()
		queue_free()
