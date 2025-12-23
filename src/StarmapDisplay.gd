extends Node2D

class_name StarmapDisplay

var starmap
var current_star
@export var scale_factor: float = 5.0

func _ready():
	if starmap:
		queue_redraw()

func _draw():
	if not starmap:
		return
	
	# Draw links first with black outline
	for link in starmap.links:
		var star1 = link["star1"]
		var star2 = link["star2"]
		var pos1 = Vector2(star1.mapx * scale_factor, star1.mapy * scale_factor)
		var pos2 = Vector2(star2.mapx * scale_factor, star2.mapy * scale_factor)
		draw_line(pos1, pos2, Color.BLACK, 3.0)  # Black outline
		draw_line(pos1, pos2, Color(0.5, 0.5, 0.5, 0.7), 1.0)  # Gray lines for links

	# Draw stars with black outline
	for star in starmap.stars:
		var pos = Vector2(star.mapx * scale_factor, star.mapy * scale_factor)
		var radius = star.radius * 2.0
		var color = get_star_color(star.starclass)
		draw_circle(pos, radius + 1.0, Color.BLACK)  # Black outline
		draw_circle(pos, radius, color)
		# Highlight current star
		if star == current_star:
			draw_circle(pos, radius + 4.0, Color.BLACK, false, 3.0)  # Black outline for highlight
			draw_circle(pos, radius + 3.0, Color.WHITE, false, 2.0)

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

func set_starmap(new_starmap: Starmap):
	starmap = new_starmap
	queue_redraw()

func set_current_star(star):
	current_star = star
	queue_redraw()
