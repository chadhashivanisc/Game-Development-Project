extends Node

const DEFENSES := [
	{"key": "tower",    "name": "Brazier",  "cost": 50,
	 "scene": "res://tower.tscn",
	 "icon": "res://assets/structures/ember_brazier/ember_brazier.png"},
	{"key": "ballista", "name": "Ballista", "cost": 150,
	 "scene": "res://ballista.tscn",
	 "icon": "res://assets/structures/thorn_ballista/thorn_ballista.png"},
	{"key": "frost",    "name": "Frost",    "cost": 200,
	 "scene": "res://frost_tower.tscn",
	 "icon": "res://assets/structures/frost_reliquary/frost_reliquary.png"},
	{"key": "shrine",   "name": "Shrine",   "cost": 250,
	 "scene": "res://shrine.tscn",
	 "icon": "res://assets/structures/soul_lantern_shrine/soul_lantern_shrine.png"},
	{"key": "cannon",   "name": "Mortar",   "cost": 350,
	 "scene": "res://cannon.tscn",
	 "icon": "res://assets/structures/rune_mortar/rune_mortar.png"},
]

var gold: int = 300
var selected_key: String = "tower"

signal gold_changed(new_gold)
signal selection_changed(key)


func info(key: String) -> Dictionary:
	for d in DEFENSES:
		if d["key"] == key:
			return d
	return {}


func can_afford(cost: int) -> bool:
	return gold >= cost


func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	gold -= cost
	gold_changed.emit(gold)
	return true


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


func select(key: String) -> void:
	selected_key = key
	selection_changed.emit(key)
