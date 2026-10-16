extends Node2D

@export var cols: int = 5
@export var rows: int = 4
@export var cell_w: int = 252
@export var cell_h: int = 107
@export var origin: Vector2 = Vector2(276, 410)

var occupied: Dictionary = {}

var tower_scene := preload("res://tower.tscn")
var cannon_scene := preload("res://cannon.tscn")

var selected_scene: PackedScene = tower_scene


func _ready() -> void:
	position = Vector2.ZERO
	draw_grid()


func draw_grid() -> void:
	var w := cols * cell_w
	var h := rows * cell_h

	for c in range(cols + 1):
		var x := origin.x + c * cell_w
		_make_bar(Vector2(x, origin.y), Vector2(2, h))

	for r in range(rows + 1):
		var y := origin.y + r * cell_h
		_make_bar(Vector2(origin.x, y), Vector2(w, 2))


func _make_bar(pos: Vector2, size: Vector2) -> void:
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([
		pos,
		pos + Vector2(size.x, 0),
		pos + size,
		pos + Vector2(0, size.y)
	])
	p.color = Color(1, 1, 1, 0.35)
	add_child(p)


func cell_from_position(pos: Vector2) -> Vector2i:
	var c := int((pos.x - origin.x) / cell_w)
	var r := int((pos.y - origin.y) / cell_h)
	return Vector2i(c, r)


func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < cols and cell.y >= 0 and cell.y < rows


func cell_center(cell: Vector2i) -> Vector2:
	return origin + Vector2(
		cell.x * cell_w + cell_w / 2.0,
		cell.y * cell_h + cell_h / 2.0
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			selected_scene = tower_scene
			print("Selected: Brazier")
		elif event.keycode == KEY_2:
			selected_scene = cannon_scene
			print("Selected: Mortar")

	if event is InputEventMouseButton and event.pressed:
		var cell := cell_from_position(event.position)
		if not is_valid_cell(cell):
			return
		if occupied.has(cell):
			print("Cell already taken")
			return
		place_defense(cell)


func place_defense(cell: Vector2i) -> void:
	var d := selected_scene.instantiate()

	if not GameState.spend(d.cost):
		print("Not enough gold")
		d.queue_free()
		return

	add_child(d)
	d.global_position = cell_center(cell)
	occupied[cell] = d
	print("Placed at ", cell)
