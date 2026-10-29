extends Node2D

@onready var spawner := $spawner
@onready var start_button := $"UI/Bottom Bar/Button"
@onready var game_over_label := $UI/GameOver
@onready var castle := $castle 


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	spawner.wave_cleared.connect(_on_wave_cleared)
	spawner.all_waves_done.connect(_on_all_done)
	castle.game_over.connect(_on_game_over)

	for child in get_children():
		if child is Node2D:
			print(child.name, "  pos=", child.position, "  global=", child.global_position, "  scale=", child.scale)


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
	
func _on_game_over() -> void:
	start_button.disabled = true
	game_over_label.visible = true
	get_tree().paused = true
