extends Node2D

@export var cols: int = 5
@export var rows: int = 5
@export var cell_size: int = 90
@export var origin: Vector2 = Vector2(300, 100)

var occupied: Dictionary = {}

var tower_scene := preload("res://tower.tscn")


func _ready() -> void:
	position = Vector2.ZERO
	print("GRID READY")
	draw_grid()


func draw_grid() -> void:
	var w := cols * cell_size
	var h := rows * cell_size

	for c in range(cols + 1):
		var x := origin.x + c * cell_size
		_make_bar(Vector2(x, origin.y), Vector2(2, h))

	for r in range(rows + 1):
		var y := origin.y + r * cell_size
		_make_bar(Vector2(origin.x, y), Vector2(w, 2))


func _make_bar(pos: Vector2, size: Vector2) -> void:
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array([
		pos,
		pos + Vector2(size.x, 0),
		pos + size,
		pos + Vector2(0, size.y)
	])
	p.color = Color(1, 1, 1)
	add_child(p)


func cell_from_position(pos: Vector2) -> Vector2i:
	var c := int((pos.x - origin.x) / cell_size)
	var r := int((pos.y - origin.y) / cell_size)
	return Vector2i(c, r)


func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < cols and cell.y >= 0 and cell.y < rows


func cell_center(cell: Vector2i) -> Vector2:
	return origin + Vector2(
		cell.x * cell_size + cell_size / 2.0,
		cell.y * cell_size + cell_size / 2.0
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var cell := cell_from_position(event.position)
		if not is_valid_cell(cell):
			return
		if occupied.has(cell):
			print("Cell already taken")
			return
		place_tower(cell)


func place_tower(cell: Vector2i) -> void:
	var t := tower_scene.instantiate()

	if not GameState.spend(t.cost):
		print("Not enough gold")
		t.queue_free()
		return

	add_child(t)
	t.global_position = cell_center(cell)
	occupied[cell] = t
	print("Placed tower at ", cell)
