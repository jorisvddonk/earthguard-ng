extends Sprite2D

class_name Planet

var planet_name = "SomePlanet"

func _init(options = {}):
	# Generate orbit
	var orbit_distance = randf() * 3000 + 1500
	var orbit_angle = randf() * 2 * PI
	position = Vector2(cos(orbit_angle) * orbit_distance, sin(orbit_angle) * orbit_distance)
	
	# Set texture
	texture = load("res://content/planets/P02.png")
	centered = true
	
	planet_name = options.get("name", "SomePlanet")

func _to_string():
	return planet_name

func tooltip_string():
	return planet_name