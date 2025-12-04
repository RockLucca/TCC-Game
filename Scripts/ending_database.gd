extends Node

# ===== BANCO DE DADOS DE FINAIS =====
# Cada final inclui: título, texto e imagem

const ENDINGS := {
	"dormir": {
		"title": "Só mais 5 minutinhos...",
		"text": "Às vezes só queremos descansar um pouco mais...",
		"image": "res://Sprites/Endings/choose_sleep.png"
	},

	"cafeina": {
		"title": "Cafeina demais",
		"text": "Café é algo viciante, pórem nem sempre seu coração vai aguentar tanto café.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"novo_rei": {
		"title": "Assuma o trono do Rei ",
		"text": "Parece que o aventureiro tinha outros planos, assim que recuperou sua espada invadiu a sala do trono com apenas o rei, e o golpeou roubando assim sua coroa.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"ansiedade": {
		"title": "Ansioso para cortar",
		"text": "A espada parecia nova em folha, e logo a ansiedade de testar veio a tona, pena que o alvo foi o pobre ferreiro.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"princesa_salva": {
		"title": "Cafeina demais",
		"text": "Café é algo viciante, pórem nem sempre seu coração vai aguentar tanto café.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"desarmado": {
		"title": "Cafeina demais",
		"text": "Café é algo viciante, pórem nem sempre seu coração vai aguentar tanto café.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"pesca": {
		"title": "Cafeina demais",
		"text": "Café é algo viciante, pórem nem sempre seu coração vai aguentar tanto café.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"inventario_cheio": {
		"title": "Cafeina demais",
		"text": "Café é algo viciante, pórem nem sempre seu coração vai aguentar tanto café.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"salto_de_fe": {
		"title": "Cafeina demais",
		"text": "Café é algo viciante, pórem nem sempre seu coração vai aguentar tanto café.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"armadilha": {
		"title": "Cafeina demais",
		"text": "Café é algo viciante, pórem nem sempre seu coração vai aguentar tanto café.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	},
	
	"pule_da_ponte": {
		"title": "Cafeina demais",
		"text": "Café é algo viciante, pórem nem sempre seu coração vai aguentar tanto café.",
		"image": "res://Sprites/Endings/choose_too_much_coffee.png"
	}
}

func get_ending(final_id: String) -> Dictionary:
	if ENDINGS.has(final_id):
		return ENDINGS[final_id]
	return {}
