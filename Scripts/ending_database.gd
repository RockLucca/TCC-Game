extends Node

# ===== BANCO DE DADOS DE FINAIS =====
# Cada final inclui: título, texto e imagem

const ENDINGS := {
	"dormir": {
		"title": "Só mais 5 minutinhos...",
		"text": "Às vezes só queremos descansar um pouco mais...",
		"image": "res://Sprites/Endings/FinalDormir.png"
	},

	"fuga": {
		"title": "Fuga Inevitável",
		"text": "Nem sempre a coragem vence o medo — às vezes só queremos sobreviver.",
		"image": "res://Sprites/Endings/final_unlocked.png"
	}
}

func get_ending(final_id: String) -> Dictionary:
	if ENDINGS.has(final_id):
		return ENDINGS[final_id]
	return {}
