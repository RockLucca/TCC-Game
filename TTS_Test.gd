extends Control

@export var SpeakButton: Button
@export var TextInput: TextEdit
@export var VoiceOption: OptionButton

var Voices: Array[Dictionary] = DisplayServer.tts_get_voices()

func _ready() -> void:
	for v in Voices:
		print(v["name"])
		$VoiceOption.add_item(v["name"])

func _process(delta: float) -> void:
	pass


func _on_speak_button_pressed() -> void:
	var text: String = $TextInput.text
	var VID: int = $VoiceOption.get_selected_id()
	var speaker: String = Voices[VID]["id"]
	DisplayServer.tts_speak(text, speaker) 


func _on_speak_button_focus_entered() -> void:
	var text: String = $SpeakButton.text
	var VID: int = $VoiceOption.get_selected_id()
	var speaker: String = Voices[VID]["id"]
	DisplayServer.tts_speak(text, speaker)


func _on_speak_button_mouse_entered() -> void:
	var text: String = $SpeakButton.text
	var VID: int = $VoiceOption.get_selected_id()
	var speaker: String = Voices[VID]["id"]
	DisplayServer.tts_speak(text, speaker)
