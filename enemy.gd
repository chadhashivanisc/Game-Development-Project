extends Area2D

@export var speed: float = 60.0
@export var damage: int = 10
@export var max_health: int = 30
@export var gold_reward: int = 20
@export var art_scene: PackedScene
@export var art_scale: float = 0.45
@export var bar_width: float = 56.0
@export var bar_gap: float = 12.0
@export var min_gap: float = 130.0
@export var attack_damage: int = 8
@export var attack_rate: float = 1.0
@export var reach: float = 95.0
@export var flinch_chance: float = 0.5

var health: int
var bar: Node2D
var spr: AnimatedSprite2D
var current_speed: float = 0.0
var attack_cooldown: float = 0.0
var attack_anim: String = "attack"
var dying: bool = false
var busy: bool = false
var engaged: Node = null


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	current_speed = speed

	var art: Node = null
	if art_scene:
		art = art_scene.instantiate()
		art.scale = Vector2(art_scale, art_scale)
		add_child(art)

	spr = _find_sprite(art)
	if spr and spr.sprite_frames:
		if not spr.sprite_frames.has_animation("attack") \
				and spr.sprite_frames.has_animation("bite"):
			attack_anim = "bite"
		_play("run")

	var shape := RectangleShape2D.new()
	shape.size = Vector2(60, 60)
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)

	bar = preload("res://health_bar.gd").new()
	add_child(bar)
	bar.setup(float(max_health), bar_width, _sprite_top(art) - bar_gap)


func _play(anim: String) -> void:
	if spr == null or spr.sprite_frames == null:
		return
	if not spr.sprite_frames.has_animation(anim):
		return
	if spr.animation != anim:
		spr.play(anim)


func _process(delta: float) -> void:
	if dying or busy:
		current_speed = 0.0
		return

	z_index = 10

	if engaged and is_instance_valid(engaged):
		current_speed = 0.0
		_play(attack_anim)
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			engaged.take_damage(attack_damage)
			attack_cooldown = 1.0 / attack_rate
		return
	engaged = null

	for d in get_tree().get_nodes_in_group("defenses"):
		if not is_instance_valid(d):
			continue
		var dn: Node2D = d
		if abs(dn.global_position.y - global_position.y) > 60.0:
			continue
		var gap: float = global_position.x - dn.global_position.x
		if gap <= 0.0 or gap >= reach:
			continue
		if dn.has_method("is_free") and not dn.is_free(self):
			continue
		engaged = dn
		dn.claim(self)
		_lunge()
		return

	var limit: float = speed
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self or not is_instance_valid(other):
			continue
		var o: Node2D = other
		var their_speed: float = float(o.get("current_speed"))
		if their_speed <= 1.0:
			continue          # it has stopped to fight — walk past it
		if abs(o.global_position.y - global_position.y) > 30.0:
			continue
		var ahead: float = global_position.x - o.global_position.x
		if ahead > 0.0 and ahead < min_gap:
			limit = min(limit, their_speed)

	current_speed = limit
	_play("run")
	position.x -= limit * delta


func _lunge() -> void:
	busy = true
	_play("leap")

	var t := create_tween()
	t.tween_property(self, "position:x", position.x - 26.0, 0.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(0.45).timeout
	busy = false


func _flinch() -> void:
	if dying or spr == null:
		return
	spr.modulate = Color(1.8, 0.6, 0.6)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(spr):
		spr.modulate = Color(1, 1, 1)


func take_damage(amount: int) -> void:
	if dying:
		return
	health -= amount
	if bar:
		bar.set_value(float(health))
	if health <= 0:
		die()
	elif randf() < flinch_chance:
		_flinch()


func die() -> void:
	if dying:
		return
	dying = true
	remove_from_group("enemies")

	if engaged and is_instance_valid(engaged) and engaged.has_method("release"):
		engaged.release(self)

	GameState.add_gold(gold_reward)

	if bar:
		bar.visible = false

	if spr and spr.sprite_frames and spr.sprite_frames.has_animation("death"):
		spr.play("death")
		await get_tree().create_timer(0.8).timeout
	queue_free()


func _sprite_top(art: Node) -> float:
	if art == null:
		return -60.0
	var s := _find_sprite(art)
	if s == null:
		return -60.0

	var tex: Texture2D = null
	if s.sprite_frames:
		var anim: String = s.animation
		if s.sprite_frames.has_animation(anim) and s.sprite_frames.get_frame_count(anim) > 0:
			tex = s.sprite_frames.get_frame_texture(anim, 0)
	if tex == null:
		return -60.0

	var img := tex.get_image()
	if img == null:
		return -60.0

	var used := img.get_used_rect()
	var top: float = float(used.position.y)
	if s.centered:
		top -= float(img.get_height()) / 2.0
	top += s.offset.y
	top = top * s.scale.y + s.position.y
	return top * art_scale


func _find_sprite(node: Node) -> AnimatedSprite2D:
	if node == null:
		return null
	if node is AnimatedSprite2D:
		return node
	for child in node.get_children():
		var found := _find_sprite(child)
		if found:
			return found
	return null
