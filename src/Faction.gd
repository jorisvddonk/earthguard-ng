class_name Faction

var id: int
var name: String
var color: Color

static var next_color: float = -0.1
const color_increment: float = 0.1

func _init(options = {}):
	next_color += color_increment
	next_color = fmod(next_color, 1.0)
	
	var default_color = Color.from_hsv(next_color, 1.0, 0.5)
	if options.has("color"):
		var c = options["color"]
		if c is String:
			color = Color(c)
		elif c is Color:
			color = c
		else:
			color = default_color
	else:
		color = default_color
	
	name = options.get("name", "Unknown")