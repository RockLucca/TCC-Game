extends Control

@export var ending_name: String  # ID do final (ex: "dormir")
@onready var image_rect = $TextureRect
@onready var title_label = $VBoxContainer/TitleLabel
@onready var description_label = $VBoxContainer/DescriptionLabel

func _ready():
	_load_ending_image()

func _load_ending_image() -> void:
	var data: Dictionary = EndingDatabase.get_ending(ending_name)

	title_label.text = data.get("title", "Final Desconhecido")
	description_label.text = data.get("text", "")

	var image_path: String = data.get("image", "")
	if FileAccess.file_exists(image_path):
		var img := Image.load_from_file(image_path)
		image_rect.texture = ImageTexture.create_from_image(img)
	else:
		push_error("Imagem do final não encontrada: " + image_path)

func _on_recomecar_pressed():
	# Reinicia o jogo
	get_tree().change_scene_to_file("res://Scenes/final_museum.tscn")
