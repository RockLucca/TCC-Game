extends CanvasLayer

@onready var panel := $PanelContainer
@onready var btn_continue := $PanelContainer/MarginContainer/VBoxContainer/ButtonContinue
@onready var btn_instructions := $PanelContainer/MarginContainer/VBoxContainer/ButtonInstructions
@onready var btn_settings := $PanelContainer/MarginContainer/VBoxContainer/ButtonSettings
@onready var btn_mainmenu := $PanelContainer/MarginContainer/VBoxContainer/ButtonMainMenu
@onready var btn_quit := $PanelContainer/MarginContainer/VBoxContainer/ButtonQuit

func _ready():
	visible = false

	# Conectar botões
	btn_continue.pressed.connect(_on_button_continue_pressed)
	btn_instructions.pressed.connect(_on_button_instructions_pressed)
	btn_settings.pressed.connect(_on_button_settings_pressed)
	btn_mainmenu.pressed.connect(_on_button_main_menu_pressed)
	btn_quit.pressed.connect(_on_button_quit_pressed)


# =====================================================
# FUNÇÕES PRINCIPAIS
# =====================================================

func toggle_pause():
	print("toggle_pause chamada. visible =", self.visible)
	if visible:
		resume_game()
	else:
		pause_game()


func pause_game():
	visible = true
	get_tree().paused = true


func resume_game():
	visible = false
	get_tree().paused = false


# =====================================================
# BOTÕES
# =====================================================

func _on_button_continue_pressed():
	resume_game()


func _on_button_instructions_pressed():
	# Aqui você abre sua tela de instruções
	print("Abrir tela de instruções")
	# get_tree().change_scene_to_file("res://Scenes/instrucoes.tscn")


func _on_button_settings_pressed():
	# Configurações -> Tela com filtros, TTS, áudio, etc
	print("Abrir tela de configurações")


func _on_button_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_button_quit_pressed():
	get_tree().quit()
