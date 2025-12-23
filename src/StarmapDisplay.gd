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
	
	# Draw links first
	for link in starmap.links:
		var star1 = link["star1"]
		var star2 = link["star2"]
		var pos1 = Vector2(star1.mapx * scale_factor, star1.mapy * scale_factor)
		var pos2 = Vector2(star2.mapx * scale_factor, star2.mapy * scale_factor)
		draw_line(pos1, pos2, Color(0.5, 0.5, 0.5, 0.7), 1.0)  # Gray lines for links
	
	# Draw stars
	for star in starmap.stars:
		var pos = Vector2(star.mapx * scale_factor, star.mapy * scale_factor)
		var radius = star.radius * 2.0
		var color = get_star_color(star.starclass)
		draw_circle(pos, radius, color)
		# Highlight current star
		if star == current_star:
			draw_circle(pos, radius + 3.0, Color.WHITE, false, 2.0)

func get_star_color(starclass: String) -> Color:
	match starclass:
		"O": return Color.BLUE
		"B": return Color(0.5, 0.5, 1.0)  # Light blue
		"A": return Color.WHITE
		"F": return Color(1.0, 1.0, 0.8)  # Pale yellow
		"G": return Color.YELLOW
		"K": return Color.ORANGE
		"M": return Color.RED
		_: return Color.GRAY

func set_starmap(new_starmap: Starmap):
	starmap = new_starmap
	queue_redraw()

func set_current_star(star):
	current_star = star
	queue_redraw()