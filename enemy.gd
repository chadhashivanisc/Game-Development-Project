extends Area2D

@export var speed: float = 60.0
@export var damage: int = 10
@export var max_health: int = 30
@export var gold_reward: int = 20

var health: int


func _ready() -> void:
	add_to_group("enemies")
	health = max_health

	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16),
		Vector2(16, 16), Vector2(-16, 16)
	])
	poly.color = Color(0.9, 0.2, 0.2)
	add_child(poly)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)


func _process(delta: float) -> void:
	position.x -= speed * delta


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()


func die() -> void:
	GameState.add_gold(gold_reward)
	queue_free()
