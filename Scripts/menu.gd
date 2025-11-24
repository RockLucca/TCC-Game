@icon("res://Sprites/ink.png")

extends Control

#Scenes control
@onready var curr_scene = $MainScreen

#Daltonic
@onready var daltonic_button = $OptionsLayer/Options/DaltonicButton
@onready var filter_menu: OptionButton = $OptionsLayer/Options/DaltonicButton

#TTS (Text to Speech)
@onready var tts_toggle := $OptionsLayer/Options/VoicesOnOff
@onready var voice_option := $OptionsLayer/Options/VoicesOptions
var voices_tts: Array[Dictionary] = DisplayServer.tts_get_voices()

#Audio
@onready var bgm_slider: HSlider = $OptionsLayer/Options/BGMVolume
@onready var sfx_slider: HSlider = $OptionsLayer/Options/SFXVolume
@onready var tts_slider: HSlider = $OptionsLayer/Options/TTSVolume

#Functions
func _ready():
	$MainScreen/ButtonBox/Play.grab_focus()
	setup_daltonic_options()
	setup_tts_voices_options()
	setup_audio_sliders()
	AudioManager.play_bgm(preload("res://SoundEffects/BGM/MenuMSC.ogg"))

func change_screen(scene):
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
	change_screen($CreditsLayer)

func _on_exit_pressed():
	get_tree().quit()

func _on_back_pressed():
	change_screen($MainScreen)
	$MainScreen/ButtonBox/Play.grab_focus()

func _toggle_fullscreen():
	#Precisa ser feito
	pass

func change_font():
	#Precisa ser feito
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
	#tts_toggle.connect("toggled", Callable(self, "_on_voices_on_off_toggled"))
	#voice_option.connect("item_selected", Callable(self, "_on_voices_options_item_selected"))

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


func setup_audio_sliders():
	# Define valores iniciais
	bgm_slider.value = AudioManager.volume_bgm
	sfx_slider.value = AudioManager.volume_sfx
	tts_slider.value = AudioManager.volume_tts

	# Conecta sinais
	if not bgm_slider.is_connected("value_changed", Callable(self, "_on_bgm_volume_changed")):
		bgm_slider.connect("value_changed", Callable(self, "_on_bgm_volume_changed"))

	if not sfx_slider.is_connected("value_changed", Callable(self, "_on_sfx_volume_changed")):
		sfx_slider.connect("value_changed", Callable(self, "_on_sfx_volume_changed"))

	if not tts_slider.is_connected("value_changed", Callable(self, "_on_tts_volume_changed")):
		tts_slider.connect("value_changed", Callable(self, "_on_tts_volume_changed"))


func _on_bgm_volume_changed(value: float):
	AudioManager.set_bgm_volume(value)


func _on_sfx_volume_changed(value: float):
	AudioManager.set_sfx_volume(value)


func _on_tts_volume_changed(value: float):
	AudioManager.set_tts_volume(value)
