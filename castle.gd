extends Area2D

@export var max_lives: int = 3
var lives: int

signal lives_changed(new_lives)
signal game_over


func _ready() -> void:
	lives = max_lives
	global_position = Vector2(100, 512)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 1024)
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)

	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.queue_free()
		lose_life()


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	print("Lives left: ", lives)
	if lives <= 0:
		game_over.emit()
		print("GAME OVER")
