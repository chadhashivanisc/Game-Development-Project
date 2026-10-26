extends Node

var gold: int = 200

signal gold_changed(new_gold)


func can_afford(cost: int) -> bool:
	return gold >= cost


func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	gold -= cost
	gold_changed.emit(gold)
	print("Gold: ", gold)
	return true


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)
	print("Gold: ", gold)
