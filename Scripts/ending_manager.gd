extends Node

var unlocked_endings: Array = []

func _ready():
	load_data()

func unlock_ending(name: String):
	if name in unlocked_endings:
		return
	
	unlocked_endings.append(name)
	save_data()
	print("Final desbloqueado:", name)

func save_data():
	var data = {"endings": unlocked_endings}
	var json = JSON.stringify(data)
	FileAccess.open("user://endings.json", FileAccess.WRITE).store_string(json)

func load_data():
	if not FileAccess.file_exists("user://endings.json"):
		return
	
	var file = FileAccess.open("user://endings.json", FileAccess.READ)
	var text = file.get_as_text()
	var parsed = JSON.parse_string(text)

	if typeof(parsed) == TYPE_DICTIONARY:
		unlocked_endings = parsed.get("endings", [])
