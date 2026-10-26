class_name Defense
extends Node2D

@export var cost: int = 50
@export var damage: int = 10
@export var fire_rate: float = 1.0
@export var attack_range: float = 300.0
@export var art_scene: PackedScene
@export var art_scale: float = 0.45
@export var projectile_scene: PackedScene

var targets: Array = []
var cooldown: float = 0.0


func _ready() -> void:
	if art_scene:
		var art := art_scene.instantiate()
		art.scale = Vector2(art_scale, art_scale)
		add_child(art)

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


func _on_area_exited(area: Area2D) -> void:
	targets.erase(area)


func _process(delta: float) -> void:
	targets = targets.filter(func(t): return is_instance_valid(t))
	cooldown -= delta
	if cooldown <= 0.0 and targets.size() > 0:
		fire(targets[0])
		cooldown = 1.0 / fire_rate


func fire(t: Node2D) -> void:
	if projectile_scene == null:
		t.take_damage(damage)
		return

	var p := projectile_scene.instantiate()
	get_parent().add_child(p)
	p.global_position = global_position + Vector2(30, -10)
	p.damage = damage
	p.target = t
