extends Node2D

var max_value: float = 1.0
var value: float = 1.0

@export var width: float = 56.0
@export var height: float = 7.0
@export var y_offset: float = -92.0
@export var fill_color: Color = Color(0.85, 0.25, 0.25)


func setup(maximum: float, w: float = 56.0, y: float = -92.0) -> void:
	max_value = maximum
	value = maximum
	width = w
	y_offset = y
	queue_redraw()


func set_value(v: float) -> void:
	value = clamp(v, 0.0, max_value)
	queue_redraw()


func _draw() -> void:
	if value >= max_value:
		return

	var x := -width / 2.0
	var top := y_offset - height
	var frac: float = value / max_value

	draw_rect(Rect2(x - 2, top - 2, width + 4, height + 4), Color(0, 0, 0, 0.75))
	draw_rect(Rect2(x, top, width, height), Color(0.15, 0.15, 0.18))
	draw_rect(Rect2(x, top, width * frac, height), fill_color)
