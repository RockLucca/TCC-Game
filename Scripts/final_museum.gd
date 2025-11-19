@icon("res://Sprites/Frame.png")


extends Control

@onready var endings_grid: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/EndingsGrid
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var back_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BackButton
@onready var play_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/PlayButton

const TOTAL_ENDINGS := Config.TOTAL_ENDINGS

func _ready() -> void:
	_update_progress_label()
	_create_ending_cards()
	back_button.connect("pressed", Callable(self, "_on_BackButton_pressed"))
	play_button.connect("pressed", Callable(self, "_on_PlayButton_pressed"))

# Atualiza o contador de progresso
func _update_progress_label() -> void:
	var unlocked = Config.get_unlocked_endings_count()
	var percent = Config.get_completion_percentage()
	progress_label.text = "Finais descobertos: %d / %d (%.1f%%)" % [unlocked, TOTAL_ENDINGS, percent]

# Cria os quadros dos finais
func _create_ending_cards() -> void:
	# Remove todos os cards antigos
	for child in endings_grid.get_children():
		child.queue_free()

	# Cria novamente com base nos finais desbloqueados
	var finais = Config.save_data["finais_obtidos"]
	for i in range(25):
		var card = TextureButton.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		card.custom_minimum_size = Vector2(64, 64)

		if i < finais.size():
			card.texture_normal = load("res://Sprites/Endings/final_unlocked.png") # imagem final desbloqueado
		else:
			card.texture_normal = load("res://Sprites/Endings/final_locked.png") # imagem com interrogação

		endings_grid.add_child(card)

# Ação ao clicar em um final desbloqueado
func _on_ending_selected(ending_id: String) -> void:
	print("Abrindo informações do final:", ending_id)
	# Aqui podemos abrir uma janela de detalhe no futuro

# Volta para a tela anterior (seleção de save)
func _on_BackButton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/save_select.tscn")

# Inicia o jogo normalmente
func _on_PlayButton_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game_interface.tscn")
