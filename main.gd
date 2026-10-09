extends Node2D

@onready var spawner := $spawner
@onready var start_button := $UI/Button


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	spawner.wave_cleared.connect(_on_wave_cleared)
	spawner.all_waves_done.connect(_on_all_done)


func _on_start_pressed() -> void:
	start_button.disabled = true
	spawner.start_wave()


func _on_wave_cleared(wave_number: int) -> void:
	GameState.add_gold(50)
	start_button.disabled = false
	print("Wave ", wave_number, " cleared.")


func _on_all_done() -> void:
	print("YOU WIN")
	start_button.disabled = true
