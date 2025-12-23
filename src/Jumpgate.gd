extends Sprite2D

class_name Jumpgate

var linkedstar = null
var static_orbit = {"distance": 500.0, "angle": 0.0}

func _init(options = {}):
	static_orbit.distance = options.get("static_orbit", {}).get("distance", 500.0)
	static_orbit.angle = options.get("static_orbit", {}).get("angle", randf() * 2 * PI)
	linkedstar = options.get("linkedstar", null)
	
	# Set texture (assuming jumppoint.png exists in content)
	texture = load("res://content/jumppoint.png")
	centered = true
	
	calc_position()

func calc_position():
	position = Vector2(cos(static_orbit.angle) * static_orbit.distance, sin(static_orbit.angle) * static_orbit.distance)

func _to_string():
	if linkedstar:
		return "Jumpgate[to " + linkedstar.name + "]"
	return "Jumpgate"

func tooltip_string():
	if linkedstar:
		return "Jumpgate to " + linkedstar.name
	return "Jumpgate"