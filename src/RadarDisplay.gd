extends Node2D

class_name RadarDisplay

var player_ship
var ships = []
var planets = []
var jumpgates = []
var star
@export var radar_radius: float = 200.0
@export var scale_factor: float = 0.02

func _draw():
	if not player_ship:
		return
	
	# Draw radar background
	draw_circle(Vector2(0, 0), radar_radius, Color(0, 0, 0, 0.5))
	draw_circle(Vector2(0, 0), radar_radius, Color.WHITE, false, 2.0)
	
	# Draw center dot for player
	draw_circle(Vector2(0, 0), 3.0, Color.GREEN)

	# Draw star at center of system
	if star:
		var star_pos = -player_ship.position * scale_factor
		if star_pos.length() <= radar_radius:
			var star_color = get_star_color(star.starclass)
			draw_circle(star_pos, 6.0, star_color)
	
	# Draw planets
	for planet in planets:
		var rel_pos = (planet.position - player_ship.position) * scale_factor
		if rel_pos.length() <= radar_radius:
			draw_circle(rel_pos, 4.0, Color.BLUE)
	
	# Draw jumpgates
	for jumpgate in jumpgates:
		var rel_pos = (jumpgate.position - player_ship.position) * scale_factor
		if rel_pos.length() <= radar_radius:
			draw_circle(rel_pos, 2.0, Color.YELLOW)
	
	# Draw ships
	for ship in ships:
		if ship == player_ship:
			continue
		var rel_pos = (ship.position - player_ship.position) * scale_factor
		if rel_pos.length() <= radar_radius:
			var color = Color.RED if ship.faction == "Pirates" else Color.CYAN
			draw_circle(rel_pos, 2.0, color)

func update_entities(p_ship, p_ships, p_planets, p_jumpgates, p_star):
	player_ship = p_ship
	ships = p_ships
	planets = p_planets
	jumpgates = p_jumpgates
	star = p_star
	queue_redraw()

func get_star_color(starclass: String) -> Color:
	match starclass:
		"O": return Color(0x9B/255.0, 0xB0/255.0, 0xFF/255.0)  # #9BB0FF
		"B": return Color(0xBB/255.0, 0xCC/255.0, 0xFF/255.0)  # #BBCCFF
		"A": return Color(0xFB/255.0, 0xF8/255.0, 0xFF/255.0)  # #FBF8FF
		"F": return Color(0xFF/255.0, 0xFF/255.0, 0xED/255.0)  # #FFFFED
		"G": return Color.YELLOW  # #FFFF00
		"K": return Color(0xFF/255.0, 0x98/255.0, 0x33/255.0)  # #FF9833
		"M": return Color(0xD2/255.0, 0x00/255.0, 0x33/255.0)  # #D20033
		_: return Color.GRAY