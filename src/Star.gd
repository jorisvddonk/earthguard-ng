extends Node2D

class_name Star

var star_name: String = ""
var mapx: float = 0.0
var mapy: float = 0.0
var radius: float = 1.0
var objid: int = 0
var starclass: String = ""
var faction: int = -1
var planets = []
var jumpgates = []

var phonetics

static var _last_id: int = 0

static func gen_id():
	_last_id += 1
	return _last_id

static func generate_starclass():
	var starClasses = ["O", "B", "A", "F", "G", "K", "M"]
	return starClasses[randi() % starClasses.size()]

func generate_name():
	return phonetics.UGenerate("Svfvsv")

func _init(options = {}):
	phonetics = Phonetics.new()
	star_name = options.get("name", generate_name())
	mapx = options.get("mapx", randf() * 100)
	mapy = options.get("mapy", randf() * 100)
	radius = options.get("radius", 1 + randf() * 3)
	objid = options.get("objid", gen_id())
	starclass = options.get("starclass", generate_starclass())
	faction = options.get("faction", -1)
	planets = options.get("planets", [])
	jumpgates = options.get("jumpgates", [])
	
	if planets.is_empty():
		planets = _gen_planets()
	
	# Add sprite
	var sprite = Sprite2D.new()
	add_child(sprite)
	
	# Set texture based on starclass
	var starClassGFXMappings = {
		"O": ["blue01", "blue02"],
		"B": ["blue04"],
		"A": ["white01", "white02"],
		"F": ["yellow01"],
		"G": ["yellow02"],
		"K": ["orange01", "orange02", "orange05"],
		"M": ["redgiant01"]
	}
	var textures = starClassGFXMappings[starclass]
	var selected_texture = textures[randi() % textures.size()]
	sprite.texture = load("res://content/stars/" + selected_texture + ".png")
	sprite.centered = true

func _gen_planets():
	var starClassProperties = {
		"O": {"minPlanets": 2, "maxPlanets": 10},
		"B": {"minPlanets": 2, "maxPlanets": 10},
		"A": {"minPlanets": 2, "maxPlanets": 10},
		"F": {"minPlanets": 2, "maxPlanets": 10},
		"G": {"minPlanets": 2, "maxPlanets": 10},
		"K": {"minPlanets": 2, "maxPlanets": 10},
		"M": {"minPlanets": 2, "maxPlanets": 10}
	}
	var props = starClassProperties[starclass]
	var n_planets = randf() * (props["maxPlanets"] - props["minPlanets"]) + props["minPlanets"]
	n_planets = max(props["minPlanets"], int(n_planets))
	var ret = []
	for i in range(n_planets):
		var planet = Planet.new()
		ret.append(planet)
	return ret

func _gen_jumpgates(otherstars):
	jumpgates = []
	for ostar in otherstars:
		var dist = sqrt((ostar.mapx - mapx)**2 + (ostar.mapy - mapy)**2)
		dist = (sqrt(dist) + 10) * 300
		var angle = atan2(ostar.mapy - mapy, ostar.mapx - mapx)
		var jg = Jumpgate.new({
			"static_orbit": {"distance": dist, "angle": angle},
			"linkedstar": ostar
		})
		jumpgates.append(jg)

func _to_string():
	return star_name

func tooltip_string():
	return star_name