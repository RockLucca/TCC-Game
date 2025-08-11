extends Node

signal filter_changed(new_type: int)
var filter_type: int = 0  # 0 = normal, 1 = protanopia, 2 = deuteranopia, 3 = tritanopia

func set_filter(type: int) -> void:
	if filter_type != type:
		filter_type = type
		emit_signal("filter_changed", filter_type)

func get_filter() -> int:
	return filter_type
