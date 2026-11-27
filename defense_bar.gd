extends HBoxContainer

var buttons := {}


func _ready() -> void:
	for d in GameState.DEFENSES:
		var slot := get_node_or_null(_slot_name(d["key"]))
		if slot == null:
			continue
		for child in slot.get_children():
			if child is Button:
				buttons[d["key"]] = child
				var k: String = d["key"]
				child.pressed.connect(func(): GameState.select(k))
				break

	GameState.selection_changed.connect(_refresh)
	_refresh(GameState.selected_key)


func _slot_name(key: String) -> String:
	match key:
		"tower": return "BrazierSlot"
		"ballista": return "BallistaSlot"
		"frost": return "FrostSlot"
		"shrine": return "ShrineSlot"
		"cannon": return "MortarSlot"
	return ""


func _refresh(key: String) -> void:
	for k in buttons:
		buttons[k].modulate = Color(1.4, 1.4, 1.4) if k == key else Color(0.85, 0.85, 0.9)
