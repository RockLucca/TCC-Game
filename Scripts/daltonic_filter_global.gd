extends CanvasLayer

@onready var color_rect := $ColorRect

func _ready():
	color_rect.material.set_shader_parameter("filter_type", 0) # Protanopia
	color_rect.material.set_shader_parameter("intensity", 0.1)
	print("Filtro inicializado!")

func set_filter_type(type: int):
	color_rect.material.set_shader_parameter("filter_type", type)

func set_intensity(value: float):
	color_rect.material.set_shader_parameter("intensity", value)
