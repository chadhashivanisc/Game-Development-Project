extends Node2D

@onready var spawner := $spawner
@onready var castle := $castle
@onready var banner := $UI/WaveBanner
@onready var start_menu := $StartMenu
@onready var game_over_label := $UI/GameOver

var current_wave: int = 0
var finished: bool = false


func _ready() -> void:
	spawner.wave_cleared.connect(_on_wave_cleared)
	spawner.all_waves_done.connect(_on_all_done)
	castle.game_over.connect(_on_game_over)
	start_menu.started.connect(_begin)


func _begin() -> void:
	await get_tree().create_timer(0.6).timeout
	_next_wave()


func _next_wave() -> void:
	if finished:
		return
	current_wave += 1
	banner.flash(current_wave)
	await get_tree().create_timer(1.6).timeout
	if finished:
		return
	spawner.start_wave()


func _on_wave_cleared(wave_number: int) -> void:
	if finished:
		return
	GameState.add_gold(80)
	print("Wave ", wave_number, " cleared")

	if wave_number >= spawner.waves.size():
		return

	await get_tree().create_timer(5.0).timeout
	_next_wave()


func _on_all_done() -> void:
	finished = true
	print("YOU WIN")


func _on_game_over() -> void:
	finished = true
	get_tree().call_group("enemies", "queue_free")
	game_over_label.visible = true
