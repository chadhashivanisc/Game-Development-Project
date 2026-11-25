extends Label


func flash(wave_number: int) -> void:
	text = "WAVE " + str(wave_number)
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	pivot_offset = size / 2.0

	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, 0.35)
	t.tween_property(self, "scale", Vector2(1.0, 1.0), 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	t.set_parallel(false)
	t.tween_interval(0.9)
	t.tween_property(self, "modulate:a", 0.0, 0.4)
	t.tween_callback(func(): visible = false)
