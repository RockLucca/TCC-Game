@icon("res://Sprites/ink.png")

extends Control

#Scenes control
@onready var curr_scene = $MainScreen
@onready var credits_text = $CreditsLayer/ControlText
@onready var credits_initial_pos = credits_text.global_position
@onready var color_rect = $DaltonicFilter

#Daltonic
@onready var daltonic_filter_rect = $DaltonicFilter
@onready var daltonic_button = $OptionsLayer/Options/DaltonicButton

#Audio
@onready var ui_audio = AudioServer.get_bus_index("UI")
@onready var master_audio = AudioServer.get_bus_index("Master")
@onready var background_audio = AudioServer.get_bus_index("Ambient")
@onready var storyteller_audio = AudioServer.get_bus_index("Storyteller")
@onready var filter_menu: OptionButton = $OptionsLayer/Options/DaltonicButton

var credits_rolling = false		#Credits
var voices_tts: Array[Dictionary] = DisplayServer.tts_get_voices()		#TTS

#Functions
func _ready():
	$MainScreen/ButtonBox/Play.grab_focus()
	setup_daltonic_options()
	
	#TTS Voice init
	for v in voices_tts:
		$OptionsLayer/Options/VoicesOptions.add_item(v["name"])
	

func setup_daltonic_options():
	# Add daltonic options
	filter_menu.add_item("Normal")
	filter_menu.add_item("Protanopia")
	filter_menu.add_item("Deuteranopia")
	filter_menu.add_item("Tritanopia")

	# Define o selecionado com base na config global
	filter_menu.select(Config.get_filter())

	# Conecta o sinal
	filter_menu.connect("item_selected", Callable(self, "_on_filter_selected"))
	
	if daltonic_filter_rect.material:
		daltonic_filter_rect.material.set("shader_parameter/filter_type", Config.get_filter())

	# Conecta ao sinal para mudar em tempo real
	Config.connect("filter_changed", Callable(self, "_on_filter_changed"))

func _on_filter_changed(new_type: int):
	if daltonic_filter_rect.material:
		daltonic_filter_rect.material.set("shader_parameter/filter_type", new_type)

func change_screen(scene):
	credits_rolling = false
	curr_scene.visible = false
	curr_scene = scene
	curr_scene.visible = true

#Buttons interactions
func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/game_interface.tscn")

func _on_instructions_pressed():
	$InstructionsLayer/Back.grab_focus()
	change_screen($InstructionsLayer)

func _on_options_pressed():
	$OptionsLayer/Back.grab_focus()
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
	var custom
	pass

#Accessibility Config Functions

#TTS Interactions
func read_button(text):
	var VID: int = $VoiceOption.get_selected_id()
	var speaker: String = voices_tts[VID]["id"]
	DisplayServer.tts_speak(text, speaker)


func _on_daltonic_button_item_selected(index):
	Config.set_filter(index)
	#save_filter_setting(index)
