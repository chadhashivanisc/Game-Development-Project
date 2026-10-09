extends Node2D

signal wave_started(wave_number)
signal wave_cleared(wave_number)
signal all_waves_done

@export var lane_ys: Array[int] = [145, 235, 325, 415, 505]
@export var spawn_x: float = 1100.0

var enemy_scene := preload("res://enemy.tscn")

# Each wave: how many enemies, and the gap between spawns.
var waves: Array = [
	{"count": 3, "gap": 1.2},
	{"count": 5, "gap": 1.0},
	{"count": 7, "gap": 0.9},
	{"count": 9, "gap": 0.8},
	{"count": 12, "gap": 0.7},
]

var current_wave: int = -1
var spawning: bool = false
var wave_active: bool = false
var to_spawn: int = 0
var spawn_timer: float = 0.0
var gap: float = 1.0


func start_wave() -> void:
	if wave_active:
		print("Wave already running")
		return

	current_wave += 1
	if current_wave >= waves.size():
		all_waves_done.emit()
		print("ALL WAVES DONE")
		return

	var w: Dictionary = waves[current_wave]
	to_spawn = w["count"]
	gap = w["gap"]
	spawn_timer = 0.0
	spawning = true
	wave_active = true

	wave_started.emit(current_wave + 1)
	print("--- WAVE ", current_wave + 1, " START ---")


func _process(delta: float) -> void:
	if spawning:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			spawn_one()
			to_spawn -= 1
			spawn_timer = gap
			if to_spawn <= 0:
				spawning = false

	if wave_active and not spawning:
		if get_tree().get_nodes_in_group("enemies").is_empty():
			wave_active = false
			wave_cleared.emit(current_wave + 1)
			print("--- WAVE ", current_wave + 1, " CLEARED ---")


func spawn_one() -> void:
	var e := enemy_scene.instantiate()
	get_parent().add_child(e)
	var y: int = lane_ys[randi() % lane_ys.size()]
	e.global_position = Vector2(spawn_x, y)
