@icon("res://Sprites/Feather.png")


extends Control

@onready var save_list_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/SaveList
@onready var new_save_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/NewSaveButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BackButton

var name_popup: Window = null
var name_line_edit: LineEdit = null
var name_confirm_button: Button = null

func _ready() -> void:
	_refresh_save_list()
	new_save_button.connect("pressed", Callable(self, "_on_new_save_pressed"))
	back_button.connect("pressed", Callable(self, "_on_back_pressed"))

# Cria o popup para digitar o nome do save
func _create_name_popup() -> void:
	name_popup = Window.new()
	name_popup.title = "Novo Save"
	name_popup.min_size = Vector2(250, 120)
	name_popup.visible = false
	add_child(name_popup)

	var vbox = VBoxContainer.new()
	name_popup.add_child(vbox)

	var label = Label.new()
	label.text = "Digite o nome do novo save:"
	vbox.add_child(label)

	name_line_edit = LineEdit.new()
	name_line_edit.placeholder_text = "Ex: Save 1"
	vbox.add_child(name_line_edit)

	name_confirm_button = Button.new()
	name_confirm_button.text = "Confirmar"
	vbox.add_child(name_confirm_button)
	name_confirm_button.connect("pressed", Callable(self, "_on_confirm_new_save"))

func _on_new_save_pressed() -> void:
	if name_popup == null:
		_create_name_popup()
	name_popup.visible = true
	name_line_edit.grab_focus()

func _on_confirm_new_save() -> void:
	var new_name = name_line_edit.text.strip_edges()
	if new_name == "":
		push_warning("Digite um nome válido.")
		return

	Config.create_new_save(new_name)
	name_popup.visible = false
	_refresh_save_list()

func _refresh_save_list() -> void:
	for child in save_list_container.get_children():
		child.queue_free()

	var saves = Config.list_saves()
	if saves.is_empty():
		var label = Label.new()
		label.text = "Nenhum save encontrado."
		save_list_container.add_child(label)
	else:
		for save_name in saves:
			var button = Button.new()
			button.text = "Save: " + save_name
			button.custom_minimum_size = Vector2(200, 40)
			button.connect("pressed", Callable(self, "_on_save_selected").bind(save_name))
			save_list_container.add_child(button)

func _on_save_selected(save_name: String) -> void:
	if Config.load_save(save_name):
		print("Save carregado:", save_name)
		get_tree().change_scene_to_file("res://Scenes/final_museum.tscn")
	else:
		push_error("Erro ao carregar save: " + save_name)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
