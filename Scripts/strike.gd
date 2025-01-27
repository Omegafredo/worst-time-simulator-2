extends AnimatedSprite2D


var Offsets = {
	0: Vector2(-4,-34),
	1: Vector2(-2, -30),
	2: Vector2(0, -18),
	3: Vector2(0, -10),
	4: Vector2(0, 24),
	5: Vector2(-2, 48)
}

func _on_frame_changed() -> void:
	if Offsets.has(frame):
		offset = Offsets[frame]

func _on_animation_finished() -> void:
	queue_free()
