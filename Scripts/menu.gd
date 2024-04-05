extends Control

@onready var curr_scene = $Main
@onready var creditos_text = $Creditos/CreditosSubindo
#@onready var credits_initial_pos = creditos_text.global_position
@onready var master_audio = AudioServer.get_bus_index("Master")
@onready var ui_audio = AudioServer.get_bus_index("UI")
@onready var guns_audio = AudioServer.get_bus_index("Guns")
@onready var ambient_audio = AudioServer.get_bus_index("Ambient")

var credits_rolling = false

func _ready():
	$Main/ButtonBox/Play.grab_focus()
	#if OS.has_feature("mobile"):
		#$Opcoes/VBoxContainer/CheckBox.hide()
	#if Global.play_credits:
		#change_screen($Creditos)
		#Global.play_credits = false

func change_screen(scene):
	credits_rolling = false
	curr_scene.visible = false
	curr_scene = scene
	#$Opcoes/VBoxContainer/CheckBox.button_pressed = Global.is_full_screen
	curr_scene.visible = true

func _process(delta: float) -> void:
	pass
	if curr_scene == $Creditos:
		if not credits_rolling:
			await get_tree().create_timer(1).timeout
			credits_rolling = true
		if not credits_rolling:
			return
		if $Creditos/CreditosSubindo/LogoMood.global_position.y >= 200:
			var scroll_speed = 30
			if Input.is_action_pressed("ui_accept"):
				scroll_speed = 180
			creditos_text.global_position.y -= delta*scroll_speed
		else:
			credits_rolling = false

#Buttons
func _on_play_pressed():
	#await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_file("res://Scenes/game_interface.tscn")

func _on_instructions_pressed():
	#await get_tree().create_timer(0.6).timeout
	$Instrucoes/VBoxContainer/Voltar.grab_focus()
	change_screen($Instrucoes)

func _on_options_pressed():
	#$Opcoes/VBoxContainer/Voltar.grab_focus()
	#await get_tree().create_timer(0.6).timeout
	change_screen($Opcoes)

func _on_credit_pressed():
	pass
	#$Creditos/Voltar.grab_focus()
	#await get_tree().create_timer(0.6).timeout
	#creditos_text.global_position = credits_initial_pos
	change_screen($Creditos)

func _on_exit_pressed():
	#await get_tree().create_timer(0.6).timeout
	get_tree().quit()

func _on_voltar_pressed() -> void:
	change_screen($Main)
	$Main/VBoxContainer/Jogar.grab_focus()

#Layers
func _toggle_fullscreen():
	pass
	#Global.is_full_screen = not Global.is_full_screen
	
	#if Global.is_full_screen:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#else:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_check_box_pressed():
	pass
	#_toggle_fullscreen()

