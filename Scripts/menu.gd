@icon("res://Sprites/ink.png")

extends Control

#Scenes control
@onready var curr_scene = $MainScreen
@onready var credits_text = $CreditsLayer/ControlText
@onready var credits_initial_pos = credits_text.global_position

#Daltonic
@onready var daltonic_button = $OptionsLayer/Options/DaltonicButton
@onready var filter_menu: OptionButton = $OptionsLayer/Options/DaltonicButton

#TTS (Text to Speech)
@onready var tts_toggle := $OptionsLayer/Options/VoicesOnOff
@onready var voice_option := $OptionsLayer/Options/VoicesOptions

#Audio
@onready var ui_audio = AudioServer.get_bus_index("UI")
@onready var master_audio = AudioServer.get_bus_index("Master")
@onready var background_audio = AudioServer.get_bus_index("Ambient")
@onready var storyteller_audio = AudioServer.get_bus_index("Storyteller")

var credits_rolling = false		#Credits
var voices_tts: Array[Dictionary] = DisplayServer.tts_get_voices()		#TTS

#Functions
func _ready():
	$MainScreen/ButtonBox/Play.grab_focus()
	setup_daltonic_options()
	setup_tts_voices_options()

func change_screen(scene):
	credits_rolling = false
	curr_scene.visible = false
	curr_scene = scene
	curr_scene.visible = true
	pass

#Buttons interactions
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/save_select.tscn")

func _on_instructions_pressed():
	$InstructionsLayer/Back.grab_focus()
	change_screen($InstructionsLayer)

func _on_options_pressed():
	$OptionsLayer/Options/Back.grab_focus()
	change_screen($OptionsLayer)

func _on_credit_pressed():
	$CreditsLayer/Back.grab_focus()
	credits_text.global_position = credits_initial_pos
	change_screen($CreditsLayer)

func _on_exit_pressed():
	get_tree().quit()

func _on_back_pressed():
	change_screen($MainScreen)
	$MainScreen/ButtonBox/Play.grab_focus()

func _toggle_fullscreen():
	pass
	Global.is_full_screen = not Global.is_full_screen
	
	if Global.is_full_screen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_check_box_pressed():
	pass
	#_toggle_fullscreen()

func change_font():
	#var custom
	pass

#Accessibility Config Functions
#TTS
func setup_tts_voices_options():
	#voice_option.clear()
	for v in TTSManager.voices:
		voice_option.add_item(v["name"])

	# Define estado inicial
	voice_option.disabled = not TTSManager.enabled
	tts_toggle.button_pressed = TTSManager.enabled

	# Conecta sinais
	tts_toggle.connect("toggled", Callable(self, "_on_voices_on_off_toggled"))
	voice_option.connect("item_selected", Callable(self, "_on_voices_options_item_selected"))

func _on_voices_on_off_toggled(toggled_on):
	TTSManager.set_enabled(toggled_on)
	voice_option.disabled = not toggled_on

func _on_voices_options_item_selected(index):
	TTSManager.set_voice(index)

#Daltonic Filter
func _on_daltonic_button_item_selected(index) -> void:
	DaltonicFilter.set_filter_type(index)

func _on_intensity_value_changed(value):
	DaltonicFilter.set_intensity(value)

func setup_daltonic_options():
	# Add daltonic options
	filter_menu.clear()
	filter_menu.add_item("Sem filtro")
	filter_menu.add_item("Protanopia")
	filter_menu.add_item("Deuteranopia")
	filter_menu.add_item("Tritanopia")

	# Define o selecionado com base na config global
	filter_menu.select(Config.get_filter())

	# Conecta o sinal (evita duplicar se já conectado)
	if not filter_menu.is_connected("item_selected", Callable(self, "_on_daltonic_button_item_selected")):
		filter_menu.connect("item_selected", Callable(self, "_on_daltonic_button_item_selected"))

	# Atualiza o filtro visual imediatamente
	Config.apply_current_filter()

	# Conecta para reagir em tempo real
	if not Config.is_connected("filter_changed", Callable(self, "_on_filter_changed")):
		Config.connect("filter_changed", Callable(self, "_on_filter_changed"))

func _on_filter_changed(new_type: int):
	filter_menu.select(new_type)
