@icon("res://Sprites/Frame.png")


extends Control

@onready var endings_grid: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/EndingsGrid
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var back_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BackButton
@onready var play_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/PlayButton

const TOTAL_ENDINGS := Config.TOTAL_ENDINGS
const EndingDatabase = preload("res://Scripts/ending_database.gd")

func _ready() -> void:
	_update_progress_label()
	_create_ending_cards()
	back_button.connect("pressed", Callable(self, "_on_BackButton_pressed"))
	play_button.connect("pressed", Callable(self, "_on_PlayButton_pressed"))
	#print("ENDINGS LOADED:", EndingDatabase.ENDINGS)
	#print("ENDING KEYS:", EndingDatabase.ENDINGS.keys())

# Atualiza o contador de progresso
func _update_progress_label() -> void:
	var unlocked = Config.get_unlocked_endings_count()
	var percent = Config.get_completion_percentage()
	progress_label.text = "Finais descobertos: %d / %d (%.1f%%)" % [unlocked, TOTAL_ENDINGS, percent]

# Cria os quadros dos finais
func _create_ending_cards() -> void:
	# Limpa cards antigos
	for child in endings_grid.get_children():
		child.queue_free()

	var finais = Config.save_data["finais_obtidos"]
	print("FINAIS OBTIDOS:", finais)
	for e in finais:
		if not EndingDatabase.ENDINGS.has(e):
			print("⚠ FINAL SALVO NÃO EXISTE NO DATABASE:", e)

	# Gera cards dinamicamente a partir dos finais existentes no EndingDatabase
	for ending_id in EndingDatabase.ENDINGS.keys():
		var card := TextureButton.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		card.custom_minimum_size = Vector2(256, 256)

		# Se o final está desbloqueado → usa a imagem real
		if finais.has(ending_id):
			var img_path = EndingDatabase.ENDINGS[ending_id].get("image", "")
			if img_path != "":
				card.texture_normal = load(img_path)
			else:
				card.texture_normal = load("res://Sprites/Endings/final_unlocked.png")
		else:
			card.texture_normal = load("res://Sprites/Endings/final_locked.png")

		# Conecta o clique passando o ID
		card.connect("pressed", Callable(self, "_on_ending_selected").bind(ending_id))

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
