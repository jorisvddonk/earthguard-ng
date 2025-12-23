extends Sprite2D

class_name Planet

const Inventory = preload("res://src/Inventory.gd")

var planet_name = "SomePlanet"
var supplies: Dictionary = {}

func _init(options = {}):
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
		supplies[cat] = randi() % 100 + 10

func _to_string():
	return planet_name

func tooltip_string():
	return planet_name

func get_supplies() -> Dictionary:
	return supplies.duplicate()