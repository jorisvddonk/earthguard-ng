extends Node2D

var planets = []
var jumpgates = []
var player_ship = null

func _ready():
	# Get reference to main node to access planets and jumpgates
	var main = get_tree().root.get_child(0)  # Assuming main is the root
	player_ship = main.player_ship
	update_targets()

func update_targets():
	var main = get_tree().root.get_child(0)
	if main and main.current_star:
		planets = main.current_star.planets
		jumpgates = main.current_star.jumpgates
	queue_redraw()

func _process(delta):
	update_targets()
	if player_ship:
		self.rotation = -player_ship.rotation

func _draw():
	if not player_ship:
		return
	
	var radius = 150  # Distance from ship to draw arrows
	
	for planet in planets:
		var direction = (planet.position - player_ship.position).normalized()
		var arrow_pos = direction * radius
		draw_arrow(arrow_pos, direction.angle(), Color.BLUE)
	
	for jumpgate in jumpgates:
		var direction = (jumpgate.position - player_ship.position).normalized()
		var arrow_pos = direction * radius
		draw_arrow(arrow_pos, direction.angle(), Color.GREEN)

func draw_arrow(pos: Vector2, angle: float, color: Color):
	angle += PI / 2  # Tangential counterclockwise
	var arrow_length = 20
	var arrow_width = 10
	var arrow_tip_length = 5
	
	# Calculate shaft
	var shaft_vector = Vector2(0, arrow_length).rotated(angle)
	var shaft_end = pos - shaft_vector
	var shaft_dir = -shaft_vector.normalized()
	var perp = shaft_dir.rotated(PI / 2) * (arrow_width / 2)
	var alongside = shaft_dir * -(arrow_length - arrow_tip_length)
	
	# Draw arrow shaft
	draw_line(pos, shaft_end, color, 2)
	
	# Draw arrow head
	var head_left = pos + perp - alongside
	var head_right = pos - perp - alongside
	draw_line(shaft_end, head_left, color, 2)
	draw_line(shaft_end, head_right, color, 2)
