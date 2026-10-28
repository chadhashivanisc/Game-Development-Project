extends CanvasLayer

@export var castle: Area2D

@onready var lives_label: Label = $"Bottom Bar/livesLabel"
@onready var gold_label: Label = $"Bottom Bar/goldLabel"


func _ready() -> void:
	GameState.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(GameState.gold)

	castle.lives_changed.connect(_on_lives_changed)
	_on_lives_changed(castle.lives)


func _on_gold_changed(new_gold: int) -> void:
	gold_label.text = "Gold: %d" % new_gold


func _on_lives_changed(new_lives: int) -> void:
	lives_label.text = "Lives: %d" % max(new_lives, 0)
