extends Node2D

@export var speed: float = 700.0
@export var art_scene: PackedScene
@export var impact_scene: PackedScene

var damage: int = 10
var target: Node2D = null


func _ready() -> void:
	if art_scene:
		add_child(art_scene.instantiate())


func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	var to_target: Vector2 = target.global_position - global_position

	if to_target.length() < 24.0:
		hit()
		return

	global_position += to_target.normalized() * speed * delta


func hit() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)

	if impact_scene:
		var fx := impact_scene.instantiate()
		get_parent().add_child(fx)
		fx.global_position = global_position
		get_tree().create_timer(0.6).timeout.connect(fx.queue_free)

	queue_free()
