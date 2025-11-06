extends Node

var enabled: bool = false
var voices: Array = []
var selected_voice_id: String = ""

func _ready():
	# Verifica se o sistema suporta TTS
	#if not DisplayServer.is_tts_available():
		#print("⚠️ TTS não suportado neste sistema.")
		#return
	
	voices = DisplayServer.tts_get_voices()
	print("✅ TTSManager iniciado. Vozes disponíveis:")
	for v in voices:
		print(" - %s (%s)" % [v["name"], v["language"]])

	# Define uma voz padrão (português se possível)
	for v in voices:
		if v["language"].begins_with("pt"):
			selected_voice_id = v["id"]
			break

	if selected_voice_id == "" and voices.size() > 0:
		selected_voice_id = voices[0]["id"]

func speak(text: String):
	if enabled and selected_voice_id != "":
		DisplayServer.tts_speak(text, selected_voice_id)
	else:
		print("🔇 TTS desativado ou voz não definida.")

func set_enabled(value: bool):
	enabled = value
	if enabled:
		speak("Leitor de tela ativado.")
	else:
		stop_all()
		print("🔕 TTS desativado.")

func stop_all():
	# Função equivalente ao 'tts_stop_all' que foi removido
	DisplayServer.tts_stop()

func set_voice(index: int):
	if index >= 0 and index < voices.size():
		selected_voice_id = voices[index]["id"]
		speak("Voz selecionada: " + voices[index]["name"])
