extends Control

@onready var save_list_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/SaveList
@onready var back_button: Button = $BackButton

const SAVE_SLOTS := ["slot_1", "slot_2", "slot_3"]

func _ready() -> void:
	_refresh_save_list()
	back_button.connect("pressed", Callable(self, "_on_back_pressed"))

func _refresh_save_list() -> void:
	# Limpa
	for child in save_list_container.get_children():
		child.queue_free()

	var saves = Config.list_saves()  # retorna um dicionário {slot: true/false}

	for slot in SAVE_SLOTS:
		var hbox := HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(300, 50)

		# Botão do slot
		var slot_button := Button.new()
		slot_button.custom_minimum_size = Vector2(250, 40)

		if saves[slot]:
			slot_button.text = "Save: " + slot
		else:
			slot_button.text = "Vazio"

		slot_button.connect("pressed", Callable(self, "_on_save_pressed").bind(slot))
		hbox.add_child(slot_button)

		# Botão deletar
		var trash_button := Button.new()
		trash_button.text = "🗑"
		trash_button.custom_minimum_size = Vector2(40, 40)
		trash_button.disabled = not saves[slot]  # só ativa se existir save
		trash_button.connect("pressed", Callable(self, "_on_delete_pressed").bind(slot))
		hbox.add_child(trash_button)

		save_list_container.add_child(hbox)

func _on_save_pressed(slot: String) -> void:
	if Config.load_save(slot):
		print("Save carregado:", slot)
		get_tree().change_scene_to_file("res://Scenes/final_museum.tscn")
	else:
		push_warning("O slot está vazio.")

func _on_delete_pressed(slot: String) -> void:
	Config.delete_save(slot)
	_refresh_save_list()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
