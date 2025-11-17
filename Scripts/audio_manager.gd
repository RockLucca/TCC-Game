

extends Node

# Volumes lineares (0 a 1)
var volume_bgm: float = 1.0
var volume_sfx: float = 1.0
var volume_tts: float = 1.0

# Referências
@onready var bgm: AudioStreamPlayer = $BGM
@onready var sfx_ui: AudioStreamPlayer = $SFXUI
@onready var tts: AudioStreamPlayer = $TTS

# Conversão para dB
const MIN_DB := -40.0

func _ready():
	load_audio_settings()
	_update_all_volumes()

func linear_to_db(value: float) -> float:
	return lerp(MIN_DB, 0.0, value)
	
func _update_all_volumes():
	bgm.volume_db = linear_to_db(volume_bgm)
	sfx_ui.volume_db = linear_to_db(volume_sfx)
	tts.volume_db = linear_to_db(volume_tts)
	
func set_bgm_volume(v: float):
	volume_bgm = clampf(v, 0.0, 1.0)
	_update_all_volumes()
	save_audio_settings()

func set_sfx_volume(v: float):
	volume_sfx = clampf(v, 0.0, 1.0)
	_update_all_volumes()
	save_audio_settings()

func set_tts_volume(v: float):
	volume_tts = clampf(v, 0.0, 1.0)
	_update_all_volumes()
	save_audio_settings()
	
func save_audio_settings():
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "bgm", volume_bgm)
	cfg.set_value("audio", "sfx", volume_sfx)
	cfg.set_value("audio", "tts", volume_tts)
	cfg.save("user://audio.cfg")

func load_audio_settings():
	var cfg := ConfigFile.new()
	var err := cfg.load("user://audio.cfg")
	if err != OK:
		return

	volume_bgm = cfg.get_value("audio", "bgm", 1.0)
	volume_sfx = cfg.get_value("audio", "sfx", 1.0)
	volume_tts = cfg.get_value("audio", "tts", 1.0)

func play_bgm(stream: AudioStream):
	if bgm.stream == stream and bgm.playing:
		return  # evita reiniciar a mesma música
		
	else:
		bgm.stream = stream
		bgm.play()

func _fade_out_and_play(new_stream: AudioStream, duration: float):
	var tween := create_tween()
	tween.tween_property(bgm, "volume_db", -40.0, duration)

	tween.finished.connect(func():
		bgm.stop()
		bgm.stream = new_stream
		bgm.volume_db = linear_to_db(volume_bgm)
		bgm.play()
		create_tween().tween_property(bgm, "volume_db", linear_to_db(volume_bgm), duration)
	)

func play_sfx_ui(stream: AudioStream):
	if stream == null:
		return
	sfx_ui.stream = stream
	sfx_ui.play()

func play_tts(stream: AudioStream):
	pass
	if stream == null:
		return
	tts.stream = stream
	tts.play()

var fade_duration := 1.5  # segundos
var _fade_tween: Tween

func play_music(track_name: String):
	var path = "res://SoundEffects/BGM/%s.ogg" % track_name

	if not ResourceLoader.exists(path):
		push_error("BGM não encontrada: " + path)
		return

	# Se já estiver tocando a mesma música, não faz nada
	if bgm.stream and bgm.stream.resource_path == path:
		return

	# Se um fade antigo estiver rolando, cancela
	if _fade_tween:
		_fade_tween.kill()

	# Criar tween
	_fade_tween = create_tween()

	# 1) FADE OUT
	if bgm.playing:
		_fade_tween.tween_property(bgm, "volume_db", MIN_DB, fade_duration)
		_fade_tween.tween_callback(Callable(self, "_finish_fade_out").bind(path))

	else:
		_finish_fade_out(path)

func _finish_fade_out(new_path: String):
	# Troca a música
	bgm.stop()
	bgm.stream = load(new_path)
	bgm.volume_db = MIN_DB
	bgm.play()

	# Criar fade in
	_fade_tween = create_tween()
	_fade_tween.tween_property(bgm, "volume_db", linear_to_db(volume_bgm), fade_duration)
