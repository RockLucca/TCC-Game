extends Node

var is_full_screen: bool = false
var current_chapter: int = 1
var play_credits = false


func _process(_delta: float) -> void:
	'''
	if Input.is_action_just_pressed("fullscreen"):
		Global.is_full_screen = not Global.is_full_screen

		if Global.is_full_screen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	'''
