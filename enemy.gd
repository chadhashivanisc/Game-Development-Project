extends Area2D

@export var speed: float = 60.0
@export var damage: int = 10
@export var max_health: int = 30
@export var gold_reward: int = 20
@export var art_scene: PackedScene
@export var art_scale: float = 0.45

var health: int


func _ready() -> void:
	add_to_group("enemies")
	health = max_health

	if art_scene:
		var art := art_scene.instantiate()
		art.scale = Vector2(art_scale, art_scale)
		add_child(art)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 60)
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
