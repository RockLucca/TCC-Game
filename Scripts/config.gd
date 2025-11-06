extends Node

signal filter_changed(new_type: int)
signal intensity_changed(new_value: float)

var filter_type: int = 0 # 0 = normal, 1 = protanopia, 2 = deuteranopia, 3 = tritanopia
var intensity: float = 1.0

func _ready():
	load_settings()
	apply_current_filter()

func set_filter(type: int) -> void:
	if filter_type != type:
		filter_type = type
		save_settings()
		apply_current_filter()
		emit_signal("filter_changed", type)

func set_intensity(value: float) -> void:
	intensity = value
	save_settings()
	apply_current_filter()
	emit_signal("intensity_changed", value)

func apply_current_filter() -> void:
	if Engine.is_editor_hint():
		return
	if "DaltonicFilter" in get_tree().get_root():
		DaltonicFilter.set_filter_type(filter_type)
		DaltonicFilter.set_intensity(intensity)

func get_filter() -> int:
	return filter_type

# --- Persistência simples ---
func save_settings() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("daltonic", "filter_type", filter_type)
	cfg.set_value("daltonic", "intensity", intensity)
	cfg.save("user://settings.cfg")

func load_settings() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load("user://settings.cfg")
	if err == OK:
		filter_type = cfg.get_value("daltonic", "filter_type", 0)
		intensity = cfg.get_value("daltonic", "intensity", 1.0)
