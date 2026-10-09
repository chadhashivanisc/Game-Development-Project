extends Node2D

@export var damage: int = 10
@export var fire_rate: float = 1.0
@export var attack_range: float = 300.0
@export var cost: int = 50
var targets: Array = []
var cooldown: float = 0.0


func _ready() -> void:
	print("TOWER READY")

	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-20, -20), Vector2(20, -20),
		Vector2(20, 20), Vector2(-20, 20)
	])
	poly.color = Color(0.2, 0.8, 0.4)
	add_child(poly)

	var shape := CircleShape2D.new()
	shape.radius = attack_range
	var col := CollisionShape2D.new()
	col.shape = shape
	$RangeArea.add_child(col)

	$RangeArea.area_entered.connect(_on_area_entered)
	$RangeArea.area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		targets.append(area)
		print("Enemy entered range")


func _on_area_exited(area: Area2D) -> void:
	targets.erase(area)


func _process(delta: float) -> void:
	targets = targets.filter(func(t): return is_instance_valid(t))

	cooldown -= delta
	if cooldown <= 0.0 and targets.size() > 0:
		shoot(targets[0])
		cooldown = 1.0 / fire_rate


func shoot(target) -> void:
	target.take_damage(damage)
	print("Tower shot an enemy")
