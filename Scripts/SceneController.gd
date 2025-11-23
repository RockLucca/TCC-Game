@icon("res://Sprites/Compass.png")

extends Node2D
class_name SceneController


@export_file("*.json") var dialog_path: String = ""
@export var text_delay: float = 0.03

var _dialog: Variant
var _current_idx: int = -1
var _current_phrase: int = 0
var _lock_scene: bool = false
var _current_scene: String = ""
var _free_when_finished: bool = false
const SCENE_IMAGES: String = "res://Sprites/Frames/"
const EndingDatabase = preload("res://Scripts/ending_database.gd")


@onready var _map: Sprite2D = $Sprites/Interface/Frame
@onready var _options_text = $TextLayer/Canvas/Options/OptionsText
@onready var _scene_text = $TextLayer/Canvas/Description/DescriptionText
@onready var pause_menu = $PauseMenu

func _ready() -> void:
	# carregar a primeira cena do arquivo json
	_dialog = _get_dialog()
	print(name + ": init dialog. File '" + dialog_path + "loaded")
	
	var track_name := _get_scene_music_name()
	AudioManager.play_music(track_name)
	
	_current_scene = "new_game_scene"
	_show_scene(_current_scene)

#
func _get_scene_index(key: String) -> int:
	var idx = -1
	for i in range(len(_dialog)):
		if _dialog[i]["scene"] == key:
			idx = i
			break
	
	if idx == -1:
		printerr(name + ": invalid scene key: " + key)
	
	return idx

#
func _fill_options(idx: int) -> void:
	_options_text.text = ""
	var options = _dialog[idx]["options"]
	
	var label:int = 1
	for opt in options:
		_options_text.text += str(label) + "-" + opt["text"] + "\n\n" 
		label += 1

#Load image for scene
func _load_scene_image(scene_key: String) -> void:
	var image_path = "%s/%s.png" % [SCENE_IMAGES, scene_key]
	
	var tex := load(image_path)
	if tex:
		_map.texture = tex
	else:
		print("Erro ao carregar imagem da cena:", image_path)


func _show_scene(key: String) -> void:
	_current_idx = _get_scene_index(key)
	if _current_idx == -1:
		return

	# mostra texto
	var scene_data = _dialog[_current_idx]
	_scene_text.text = _dialog[_current_idx]["text"]

	# carrega o sprite da cena
	_load_scene_image(scene_data["scene"])

	# mostra opções
	_fill_options(_current_idx)
	
	if TTSManager.enabled:
		var narration_text = ""

		# Adiciona a localização da cena (ex: "Casa do Soldado")
		if scene_data.has("local"):
			narration_text += "Local: " + scene_data["local"] + ". "

		# Adiciona o texto descritivo
		narration_text += scene_data["text"].strip_edges() + " "

		# Lê as opções disponíveis
		if scene_data.has("options"):
			narration_text += "Suas opções são: "
			for option in scene_data["options"]:
				narration_text += option["text"] + ". "

		# Fala tudo de uma vez
		TTSManager.speak(narration_text)


func _reset() -> void:
	visible = false
	_current_phrase = 0
	set_process(false)

	if _free_when_finished:
		queue_free()

func _get_scene_music_name() -> String:
	var file_name = dialog_path.get_file()          # CasaSoldado.json
	return file_name.get_basename()                 # CasaSoldado

func _get_dialog() -> Array:
	# check of condition is true or crash the game with the error message
	assert(FileAccess.file_exists(dialog_path), "%s: json file does not exist" % name)
	
	# extract data from file
	var file: FileAccess = FileAccess.open(dialog_path, FileAccess.READ)
	var json: String = file.get_as_text()

	var test_json_conv = JSON.new()
	test_json_conv.parse(json)
	var output = test_json_conv.get_data()
	#print(JSON.stringify(output, "\t"))
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []


func select_option(opt: int):
	if _lock_scene:
		return
	if _current_scene == "ending_scene":
		_restart_game()
		return
	
	var options = _dialog[_current_idx]["options"]
	if opt < 0 or opt >= len(options):
		return
	var option = options[opt]

	#1) Verifica se é um final ---
	if option.has("ending"):
		var ending_id = option["ending"]

		Config.unlock_final(ending_id)
		var ending_data = EndingDatabase.ENDINGS.get(ending_id, {})

		# Texto do final
		if ending_data.has("text"):
			_scene_text.text = ending_data["text"]
		else:
			_scene_text.text = "Fim da história."

		# Imagem do final   (CORRIGIDO)
		if ending_data.has("image"):
			var tex := load(ending_data["image"])  # carrega como recurso importado
			if tex is Texture2D:
				_map.texture = tex

		# Remover opções e colocar só 'recomeçar'
		_options_text.text = "1 - Recomeçar"
		_current_scene = "ending_scene"
		print("ENDING DATA:", ending_data)
		print("HAS TEXT:", ending_data.has("text"))
		print("HAS IMAGE:", ending_data.has("image"))

		return

	#2) Verifica troca de área ---
	if option.has("change_area"):
		change_chapter(option["change_area"])
		return

	#3) Continua o fluxo normal ---
	_current_scene = option["next"]

	if _current_scene != "none":
		_show_scene(_current_scene)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:# and event.keycode == KEY_ESCAPE:
			select_option(event.keycode - 49)
			print(event.keycode)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("ESC detectado")
		pause_menu.toggle_pause()

func change_chapter(area_name: String):
	var new_path = "res://Scripts/%s.json" % area_name

	if not FileAccess.file_exists(new_path):
		push_error("Arquivo de área não encontrado: " + new_path)
		return

	dialog_path = new_path
	_dialog = _get_dialog()

	# Mantém a cena que o player deveria ir
	_show_scene(_current_scene)

	# Troca a música da área
	AudioManager.play_music(area_name)

func _restart_game():
	get_tree().change_scene_to_file("res://Scenes/final_museum.tscn")
