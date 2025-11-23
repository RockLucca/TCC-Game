extends Node

# --- VARIÁVEIS ---
var current_save_path: String = ""
var save_data: Dictionary = {}

# --- CONSTANTES ---
const SAVE_DIR := "user://saves/"
const GLOBAL_SETTINGS := "user://settings.cfg"

# --- ESTRUTURA PADRÃO DE UM SAVE ---
const DEFAULT_SAVE := {
	"finais_obtidos": [],
	"configuracoes": {
		"tts_ativo": false,
		"voz": "pt-br-1",
		"filter_type": 0,   # 0 = normal, 1 = protanopia, 2 = deuteranopia, 3 = tritanopia
		"intensity": 1.0
	}
}

const SAVE_SLOTS = ["slot_1", "slot_2", "slot_3"]

signal filter_changed(new_filter_type)

# --- AO INICIAR ---
func _ready() -> void:
	# Garante que a pasta de saves existe
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

	# Carrega configurações globais (daltonismo, etc.)
	load_global_settings()
	apply_current_filter()


# =======================================================
# ============= SISTEMA DE SALVAMENTO ====================
# =======================================================

func create_new_save(slot_name: String) -> void:
	current_save_path = SAVE_DIR + slot_name + ".json"
	save_data = DEFAULT_SAVE.duplicate(true)
	_save_to_file()
	print("Novo save criado:", current_save_path)

func load_save(slot_name: String) -> bool:
	var path = SAVE_DIR + slot_name + ".json"
	if not FileAccess.file_exists(path):
		print("Save não encontrado:", path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var json_result = JSON.parse_string(content)
	if typeof(json_result) == TYPE_DICTIONARY:
		save_data = json_result
		current_save_path = path
		print("Save carregado:", path)

		# Aplica configurações do save (daltonismo, TTS etc)
		apply_current_filter()
		return true
	else:
		push_error("Erro ao carregar o JSON do save.")
		return false

func _save_to_file() -> void:
	if current_save_path == "":
		push_error("Nenhum caminho de save definido!")
		return
	var file = FileAccess.open(current_save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Progresso salvo em:", current_save_path)

func unlock_final(final_id: String) -> void:
	if final_id in save_data["finais_obtidos"]:
		return
	save_data["finais_obtidos"].append(final_id)
	_save_to_file()
	print("Final desbloqueado:", final_id)

func has_final(final_id: String) -> bool:
	return final_id in save_data["finais_obtidos"]

func list_saves():
	var result := {}

	for slot in SAVE_SLOTS:
		var path := "user://saves/%s.json" % slot

		# Se o arquivo não existe, cria um save vazio automaticamente
		if not FileAccess.file_exists(path):
			var new_save = DEFAULT_SAVE.duplicate(true)
			var file = FileAccess.open(path, FileAccess.WRITE)
			file.store_string(JSON.stringify(new_save, "\t"))
			file.close()

			result[slot] = false  # existe agora, mas está vazio
		else:
			# Arquivo existe → é um save válido
			result[slot] = true
	return result
	
# =======================================================
# ============= PROGRESSO E ESTATÍSTICAS ================
# =======================================================

# Define dados temporários de progresso (sem sobrescrever o save até salvar)
var current_progress := {
	"scene": "",          # Cena ou chave atual
	"choices": [],        # Lista de escolhas feitas
	"playtime": 0.0       # Tempo jogado acumulado
}

# Define o número total de finais possíveis (ajuste conforme o jogo cresce)
const TOTAL_ENDINGS := 50

# Atualiza a cena atual (para salvar em checkpoints)
func update_progress(scene_name: String, choices: Array = []) -> void:
	current_progress["scene"] = scene_name
	current_progress["choices"] = choices
	_save_to_file()

# Salva o progresso do jogador dentro do JSON atual
func save_checkpoint() -> void:
	if current_save_path == "":
		return
	save_data["progresso"] = current_progress
	_save_to_file()

# Retorna quantos finais o jogador já descobriu
func get_unlocked_endings_count() -> int:
	return save_data["finais_obtidos"].size()

# Retorna a porcentagem de finais encontrados
func get_completion_percentage() -> float:
	return float(get_unlocked_endings_count()) / float(TOTAL_ENDINGS) * 100.0

# Redefine completamente o progresso (sem apagar configs)
func reset_progress() -> void:
	save_data["finais_obtidos"].clear()
	current_progress = {"scene": "", "choices": [], "playtime": 0.0}
	_save_to_file()
	print("Progresso reiniciado.")


# =======================================================
# ============= SISTEMA DE CONFIGURAÇÕES =================
# =======================================================

# --- Daltonismo ---
func set_filter(type: int) -> void:
	if get_config("filter_type") != type:
		set_config("filter_type", type)
		save_global_settings()
		apply_current_filter()
		emit_signal("filter_changed", type)

func set_intensity(value: float) -> void:
	set_config("intensity", value)
	save_global_settings()
	apply_current_filter()
	emit_signal("intensity_changed", value)

func apply_current_filter() -> void:
	if Engine.is_editor_hint():
		return

	# Garante que a árvore de cenas está disponível
	if not Engine.has_singleton("SceneTree"):
		return

	var tree = Engine.get_main_loop()
	if tree == null:
		return

	var root = tree.root
	if root == null:
		return

	if root.has_node("DaltonicFilter"):
		var filter_node = root.get_node("DaltonicFilter")
		filter_node.set_filter_type(get_config("filter_type"))
		filter_node.set_intensity(get_config("intensity"))

func get_filter() -> int:
	return get_config("filter_type")


# --- Get/Set genérico de configs (TTS, filtro etc) ---
func set_config(key: String, value) -> void:
	if not save_data.has("configuracoes"):
		save_data["configuracoes"] = {}
	save_data["configuracoes"][key] = value
	if current_save_path != "":
		_save_to_file()

func get_config(key: String):
	if save_data.has("configuracoes") and key in save_data["configuracoes"]:
		return save_data["configuracoes"][key]
	return null

func delete_save(slot_name: String) -> void:
	var path := SAVE_DIR + "%s.json" % slot_name

	# Se o arquivo existir, apagamos
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Save deletado:", path)
	else:
		print("Nenhum arquivo para deletar:", path)

	# Recria um save vazio automaticamente
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(DEFAULT_SAVE, "\t"))
	file.close()

	# Se deletou o save que estava carregado, limpa os dados atuais
	if current_save_path == path:
		current_save_path = ""
		save_data = DEFAULT_SAVE.duplicate(true)
	print("Novo save vazio criado no slot:", slot_name)


# =======================================================
# ============ CONFIGURAÇÕES GLOBAIS =====================
# =======================================================

func save_global_settings() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("daltonic", "filter_type", get_config("filter_type"))
	cfg.set_value("daltonic", "intensity", get_config("intensity"))
	cfg.save(GLOBAL_SETTINGS)

func load_global_settings() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load(GLOBAL_SETTINGS)
	if err == OK:
		set_config("filter_type", cfg.get_value("daltonic", "filter_type", 0))
		set_config("intensity", cfg.get_value("daltonic", "intensity", 1.0))
