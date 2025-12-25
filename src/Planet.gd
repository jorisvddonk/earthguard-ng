extends Sprite2D

class_name Planet

const Inventory = preload("res://src/Inventory.gd")
const Phonetics = preload("res://src/Phonetics.gd")

var planet_name = "SomePlanet"
var supplies: Dictionary = {}
var prices: Dictionary = {}
var phonetics

func _init(options = {}):
	phonetics = Phonetics.new()
	
	# Generate orbit
	var orbit_distance = randf() * 3000 + 1500
	var orbit_angle = randf() * 2 * PI
	position = Vector2(cos(orbit_angle) * orbit_distance, sin(orbit_angle) * orbit_distance)
	
	# Set texture
	texture = load("res://content/planets/P02.png")
	centered = true
	
	planet_name = options.get("name", "SomePlanet")
	
	# Initialize supplies
	for cat in Inventory.CATEGORIES:
		if cat == "Credits":
			supplies[cat] = randi() % 10000 + 1000
		else:
			supplies[cat] = randi() % 100 + 10
	
	# Initialize prices
	for cat in Inventory.CATEGORIES:
		if cat == "Credits":
			prices[cat] = {"buy_price": 1, "sell_price": 1}  # Credits are currency
		else:
			var base_price = randi() % 100 + 10  # Random base price between 10 and 109
			var margin = randi() % 20 + 5  # Margin between 5 and 24
			prices[cat] = {
				"buy_price": base_price + margin,
				"sell_price": base_price - margin
			}

func _to_string():
	return planet_name

func tooltip_string():
	return planet_name

func get_supplies() -> Dictionary:
	return supplies.duplicate()

func get_prices() -> Dictionary:
	return prices.duplicate()
