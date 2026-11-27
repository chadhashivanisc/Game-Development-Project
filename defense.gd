class_name Defense
extends Node2D

@export var cost: int = 50
@export var damage: int = 10
@export var fire_rate: float = 1.0
@export var attack_range: float = 300.0
@export var art_scene: PackedScene
@export var art_scale: float = 0.45
@export var projectile_scene: PackedScene
@export var max_health: int = 120
@export var bar_width: float = 50.0
@export var bar_y: float = -92.0
@export var turret_offset_deg: float = 0.0
@export var turret_limit_deg: float = 40.0
@export var turret_speed: float = 6.0

var health: int
var bar: Node2D
var turret: Node2D
var attacker: Node = null
var targets: Array = []
var cooldown: float = 0.0


func _ready() -> void:
	add_to_group("defenses")
	health = max_health

	var art: Node = null
	if art_scene:
		art = art_scene.instantiate()
		art.scale = Vector2(art_scale, art_scale)
		add_child(art)

		var ap := _find_anim_player(art)
		if ap:
			ap.stop()

		turret = _find_turret(art)

	var shape := CircleShape2D.new()
	shape.radius = attack_range
	var col := CollisionShape2D.new()
	col.shape = shape
	$RangeArea.add_child(col)

	$RangeArea.area_entered.connect(_on_area_entered)
	$RangeArea.area_exited.connect(_on_area_exited)

	bar = preload("res://health_bar.gd").new()
	bar.fill_color = Color(0.35, 0.8, 0.4)
	add_child(bar)
	bar.setup(float(max_health), bar_width, bar_y)


func _find_turret(node: Node) -> Node2D:
	if node is Node2D:
		var n: String = String(node.name)
		if n.begins_with("Attack") or n == "CannonBarrel":
			return node
	for child in node.get_children():
		var found := _find_turret(child)
		if found:
			return found
	return null


func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_anim_player(child)
		if found:
			return found
	return null


func is_free(by: Node) -> bool:
	if attacker == by:
		return true
	return attacker == null or not is_instance_valid(attacker)


func claim(by: Node) -> void:
	attacker = by


func release(by: Node) -> void:
	if attacker == by:
		attacker = null


func take_damage(amount: int) -> void:
	health -= amount
	if bar:
		bar.set_value(float(health))
	if health <= 0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		targets.append(area)


func _on_area_exited(area: Area2D) -> void:
	targets.erase(area)


func _process(delta: float) -> void:
	targets = targets.filter(func(t): return is_instance_valid(t))

	if turret:
		var want: float = deg_to_rad(turret_offset_deg)
		if targets.size() > 0:
			var t: Node2D = targets[0]
			want = (t.global_position - global_position).angle() \
				+ deg_to_rad(turret_offset_deg)
			var lim := deg_to_rad(turret_limit_deg)
			want = clamp(want, -lim, lim)
		turret.rotation = lerp_angle(turret.rotation, want, turret_speed * delta)

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
