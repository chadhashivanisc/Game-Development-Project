extends Node2D

signal wave_started(wave_number)
signal wave_cleared(wave_number)
signal all_waves_done

@export var lane_ys: Array[int] = [464, 571, 678, 785]
@export var spawn_x: float = 1500.0

var enemy_scenes := {
	"thrall": preload("res://enemy.tscn"),
	"hound": preload("res://enemy_hound.tscn"),
	"penitent": preload("res://enemy_penitent.tscn"),
	"boss": preload("res://enemy_boss.tscn"),
}

# Each wave is a list of groups. Groups spawn one after another.
var waves: Array = [
	[ {"type": "thrall", "count": 4, "gap": 1.2} ],

	[ {"type": "thrall", "count": 4, "gap": 1.0},
	  {"type": "hound",  "count": 3, "gap": 0.7} ],

	[ {"type": "hound",    "count": 5, "gap": 0.6},
	  {"type": "penitent", "count": 2, "gap": 1.5} ],

	[ {"type": "thrall",   "count": 6, "gap": 0.8},
	  {"type": "penitent", "count": 4, "gap": 1.2},
	  {"type": "hound",    "count": 4, "gap": 0.5} ],

	[ {"type": "hound",    "count": 6, "gap": 0.5},
	  {"type": "penitent", "count": 3, "gap": 1.0},
	  {"type": "boss",     "count": 1, "gap": 2.0} ],
]

var current_wave: int = -1
var queue: Array = []          # flattened list of scenes still to spawn
var gaps: Array = []           # matching delay before each one
var spawning: bool = false
var wave_active: bool = false
var spawn_timer: float = 0.0


func start_wave() -> void:
	if wave_active:
		print("Wave already running")
		return

	current_wave += 1
	if current_wave >= waves.size():
		all_waves_done.emit()
		print("ALL WAVES DONE")
		return

	queue.clear()
	gaps.clear()

	for group in waves[current_wave]:
		var scene: PackedScene = enemy_scenes[group["type"]]
		for i in range(group["count"]):
			queue.append(scene)
			gaps.append(group["gap"])

	spawn_timer = 0.0
	spawning = true
	wave_active = true

	wave_started.emit(current_wave + 1)
	print("--- WAVE ", current_wave + 1, " START (", queue.size(), " enemies) ---")


func _process(delta: float) -> void:
	if spawning:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			spawn_next()

	if wave_active and not spawning:
		if get_tree().get_nodes_in_group("enemies").is_empty():
			wave_active = false
			wave_cleared.emit(current_wave + 1)
			print("--- WAVE ", current_wave + 1, " CLEARED ---")


func spawn_next() -> void:
	if queue.is_empty():
		spawning = false
		return

	var scene: PackedScene = queue.pop_front()
	spawn_timer = gaps.pop_front()

	var e := scene.instantiate()
	get_parent().add_child(e)
	var y: int = lane_ys[randi() % lane_ys.size()]
	e.global_position = Vector2(spawn_x, y)
