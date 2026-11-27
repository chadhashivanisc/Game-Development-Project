extends Node2D

const ROW_Y := [410, 520, 654, 808]   # 4 boundaries = 3 rows
const ROW_W := [150, 158, 170]        # cell width per row
const CENTRE_X := 726
const COLS := 6

var occupied: Dictionary = {}
var hover: Polygon2D


func _ready() -> void:
	position = Vector2.ZERO
	hover = Polygon2D.new()
	hover.color = Color(1, 0.85, 0.4, 0.25)
	hover.visible = false
	add_child(hover)


func row_left(row: int) -> float:
	return CENTRE_X - 3.0 * ROW_W[row]


func cell_from_position(pos: Vector2) -> Vector2i:
	var row := -1
	for r in range(3):
		if pos.y >= ROW_Y[r] and pos.y < ROW_Y[r + 1]:
			row = r
			break
	if row < 0:
		return Vector2i(-1, -1)

	var col := int(floor((pos.x - row_left(row)) / ROW_W[row]))
	return Vector2i(col, row)


func is_valid_cell(cell: Vector2i) -> bool:
	return cell.y >= 0 and cell.y < 3 and cell.x >= 0 and cell.x < COLS


func cell_rect(cell: Vector2i) -> Rect2:
	var w: float = ROW_W[cell.y]
	var x := row_left(cell.y) + cell.x * w
	var y: float = ROW_Y[cell.y]
	var h: float = ROW_Y[cell.y + 1] - y
	return Rect2(x, y, w, h)


func cell_center(cell: Vector2i) -> Vector2:
	var r := cell_rect(cell)
	return r.position + r.size / 2.0


func _process(_delta: float) -> void:
	var cell := cell_from_position(get_viewport().get_mouse_position())

	if not is_valid_cell(cell) or occupied.has(cell):
		hover.visible = false
		return

	var r := cell_rect(cell)
	hover.polygon = PackedVector2Array([
		r.position,
		r.position + Vector2(r.size.x, 0),
		r.position + r.size,
		r.position + Vector2(0, r.size.y)
	])
	hover.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := cell_from_position(event.position)
		if not is_valid_cell(cell) or occupied.has(cell):
			return
		place_defense(cell)


func place_defense(cell: Vector2i) -> void:
	var d: Dictionary = GameState.info(GameState.selected_key)
	if d.is_empty():
		return

	if not GameState.spend(d["cost"]):
		print("Cannot afford ", GameState.selected_key,
			" costing ", d["cost"], " — you have ", GameState.gold)
		return

	var scene := load(d["scene"]) as PackedScene
	if scene == null:
		return

	var node := scene.instantiate()
	add_child(node)
	node.global_position = cell_center(cell)
	occupied[cell] = node
