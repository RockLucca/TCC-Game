@icon("res://Sprites/Compass.png")

extends Node2D
class_name SceneController


@export_file("*.json") var dialog_path: String = ""
@export var text_delay: float = 0.03

var _dialog: Variant
var inventory: Array = []
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
@onready var inventory_box = $Sprites/InventoryItens

var item_sprites := {
	"Espada": "Espada",
	"Escudo": "Escudo",
	"Bomba": "Bomba",
	"Gancho": "Gancho",
	"Pa": "Pa",
	"VaraPesca": "VaraPesca",
	"Mapa": "Mapa"
}


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
		image_path = "res://Sprites/Endings/final_locked.png"
		var tex2 := load(image_path)
		_map.texture = tex2

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

	# ---------------------------------------------------------
	# 1) SISTEMA DE REQUIRE / FAIL
	# ---------------------------------------------------------
	if option.has("require"):
		var missing := false
		for item in option["require"]:
			if item not in inventory:
				missing = true
				break
		
		if missing:
			# Exibe mensagem de falha se existir
			if option.has("fail"):
				_scene_text.text = option["fail"]
			else:
				_scene_text.text = "Você não possui os itens necessários."
			
			_fill_options(_current_idx)  # mantém as opções atuais
			return
	# ---------------------------------------------------------

	# ---------------------------------------------------------
	# 2) SISTEMA DE GRANT (adicionar itens ao inventário)
	# ---------------------------------------------------------
	if option.has("grant"):
		for item in option["grant"]:
			if item not in inventory:
				inventory.append(item)
				_show_item_sprite(item)
	# ---------------------------------------------------------

	# ---------------------------------------------------------
	# 3) Finais, trocas, etc
	# ---------------------------------------------------------

	#Final
	if option.has("ending"):
		var ending_id = option["ending"]

		Config.unlock_final(ending_id)
		var ending_data = EndingDatabase.ENDINGS.get(ending_id, {})

		if ending_data.has("text"):
			_scene_text.text = ending_data["text"]
		else:
			_scene_text.text = "Fim da história."

		if ending_data.has("image"):
			var tex := load(ending_data["image"])
			if tex is Texture2D:
				_map.texture = tex

		_options_text.text = "1 - Recomeçar"
		_current_scene = "ending_scene"
		return

	#Troca de área
	if option.has("change_area"):
		change_chapter(option["change_area"])
		return

	# Continua fluxo normal
	_current_scene = option["next"]

	if _current_scene != "none":
		_show_scene(_current_scene)


	#2) Verifica troca de área ---
	if option.has("change_area"):
		change_chapter(option["change_area"])
		return

	#3) Continua o fluxo normal ---
	_current_scene = option["next"]

	if _current_scene != "none":
		_show_scene(_current_scene)

func _show_item_sprite(item_name: String):
	if item_sprites.has(item_name):
		var node_name = item_sprites[item_name]
		var sprite_node = inventory_box.get_node_or_null(node_name)
		
		if sprite_node:
			sprite_node.visible = true
			print("Item mostrado no inventário:", item_name)
		else:
			print("Sprite não encontrado para:", node_name)
	else:
		print("Item sem sprite mapeado:", item_name)


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
