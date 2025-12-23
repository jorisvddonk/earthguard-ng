extends Node2D

signal star_changed(star)

var Bullet = load("res://src/Bullet.tscn")
var Starmap = load("res://src/Starmap.gd")
var Planet = load("res://src/Planet.gd")
var Jumpgate = load("res://src/Jumpgate.gd")
var Ship = load("res://src/Ship.tscn")
var Task = load("res://src/Task.gd")
var Target = load("res://src/Target.gd")
var DirectionalIndicator = load("res://src/DirectionalIndicator.gd")
var starmap
var current_star
var player_ship
var jump_cooldown = 0.0
var starmap_display
var nebula

func _ready():
	# Create starmap
	starmap = Starmap.new()
	current_star = starmap.stars[0]

	# Get starmap display from scene
	starmap_display = $CanvasLayer/StarmapDisplay
	starmap_display.starmap = starmap
	starmap_display.current_star = current_star
	connect("star_changed", Callable(starmap_display, "set_current_star"))

	# Get nebula for dynamic coloring
	nebula = %Nebula

	# Add planets and jumpgates
	add_planets_and_jumpgates()

	# Set up player ship
	player_ship = $PlayerShip
	player_ship.position = Vector2(200, 300)
	player_ship.texture = load("res://content/ship.png")
	player_ship.z_index = 1

	# Connect shooting
	player_ship.connect("shoot", Callable(self, "_on_Ship_shoot").bind(null, player_ship))

	# Spawn AI ships
	spawn_ai_ships()

	# Set up camera
	var camera = Camera2D.new()
	player_ship.add_child(camera)
	camera.make_current()

	# Add directional indicator
	var indicator = Node2D.new()
	indicator.script = DirectionalIndicator
	player_ship.add_child(indicator)

func add_planets_and_jumpgates():
	for planet in current_star.planets:
		add_child(planet)
		planet.z_index = 0
	for jumpgate in current_star.jumpgates:
		add_child(jumpgate)
		jumpgate.z_index = 0

func spawn_ai_ships():
	for i in range(30):
		spawn_random_ship()

func spawn_random_ship():
	var factions = ["Civilians", "Civilians", "Civilians", "Pirates", "Police", "Police", "AnnoyingFan"]
	var faction = factions[randi() % factions.size()]
	
	var gfxID = {
		"Civilians": "ship2",
		"Pirates": "ship5",
		"Police": "ship6",
		"AnnoyingFan": "ship7"
	}[faction]
	
	var ship_scene = Ship.instantiate()
	ship_scene.faction = faction
	ship_scene.position = Vector2(randf_range(-750, 750), randf_range(-750, 750))
	ship_scene.velocity = Vector2(randf_range(-1.5, 3.5), randf_range(-1.5, 3.5))
	
	# Set graphics
	if ship_scene.has_node("Sprite2D"):
		ship_scene.get_node("Sprite2D").texture = load("res://content/" + gfxID + ".png")
	
	add_child(ship_scene)
	ship_scene.z_index = 1
	
	# Connect signals
	ship_scene.get_subsystems().autopilot.connect("complete", Callable(self, "_on_autopilot_complete").bind(ship_scene))
	ship_scene.get_subsystems().ai.connect("target_lost", Callable(self, "_on_ai_target_lost").bind(ship_scene))
	
	# Set initial task
	set_next_task_for_ship(ship_scene)
	
	ship_scene.connect("shoot", Callable(self, "_on_Ship_shoot").bind(ship_scene))

func set_next_task_for_ship(ship):
	var faction = ship.faction
	var ai = ship.get_subsystems().ai
	var task
	if faction == "Civilians":
		if current_star.planets.size() > 0:
			var planet = current_star.planets[randi() % current_star.planets.size()]
			var target = Target.new(Target.TargetType.GAMEOBJECT, planet)
			task = Task.new(Task.TaskType.MOVE, target)
		else:
			task = Task.new(Task.TaskType.IDLE)
	elif faction == "Pirates":
		var target_ship = find_ship_of_faction("Civilians")
		if target_ship:
			var target = Target.new(Target.TargetType.SHIP, target_ship)
			task = Task.new(Task.TaskType.ATTACK, target)
		else:
			task = Task.new(Task.TaskType.IDLE)
	elif faction == "Police":
		var target_ship = find_ship_of_faction("Pirates")
		if target_ship:
			var target = Target.new(Target.TargetType.SHIP, target_ship)
			task = Task.new(Task.TaskType.ATTACK, target)
		else:
			task = Task.new(Task.TaskType.IDLE)
	elif faction == "AnnoyingFan":
		var target = Target.new(Target.TargetType.SHIP, player_ship)
		task = Task.new(Task.TaskType.FOLLOW, target)
	else:
		task = Task.new(Task.TaskType.IDLE)
	ai.set_task(task)

func find_ship_of_faction(target_faction: String):
	for child in get_children():
		if child is Node2D and child.has_method("get_subsystems") and child != player_ship:
			if child.faction == target_faction:
				return child
	return null

func _on_autopilot_complete(ship):
	set_next_task_for_ship(ship)

func _on_ai_target_lost(ship):
	set_next_task_for_ship(ship)

func _on_Ship_shoot(targetpos, ship):
	var bullet = Bullet.instantiate()
	var rot = ship.rotation
	if targetpos != null:
		rot = Vector2.UP.angle_to(targetpos - ship.position)
	bullet.set_velocity(ship.velocity + Vector2(0, -300).rotated(rot))
	bullet.position = ship.position
	bullet.rotation = ship.rotation
	bullet.shooter = ship  # Set the shooter for collision
	bullet.z_index = 2
	add_child(bullet)

func _physics_process(delta):
	# Update jump cooldown
	if jump_cooldown > 0:
		jump_cooldown -= delta

	# Handle collisions
	for child in get_children():
		if child.has_method("set_velocity"):  # It's a bullet
			for ship in get_children():
				if ship is Node2D and ship.has_method("get_subsystems") and ship != child.owner:
					var dist = child.position.distance_to(ship.position)
					if dist < 30:  # collision radius
						ship.emit_signal("hit", {"damage": 1, "perpetrator": child.shooter})
						child.queue_free()
						break

	# Handle jump gate interactions
	if jump_cooldown <= 0:
		for jumpgate in current_star.jumpgates:
			if player_ship.position.distance_to(jumpgate.position) < 50:
				if jumpgate.linkedstar:
					jump_to_star(jumpgate.linkedstar)
				break

func jump_to_star(new_star):
	var old_star = current_star
	current_star = new_star
	# Clear old planets, jumpgates, and AI ships
	for child in get_children():
		if child is Planet or child is Jumpgate:
			remove_child(child)
		elif child != player_ship and child.has_method("get_subsystems"):  # AI ships
			child.queue_free()
	# Add new planets and jumpgates
	add_planets_and_jumpgates()
	# Find the incoming jumpgate (the one linking back to old_star)
	var incoming_jumpgate = null
	for jumpgate in current_star.jumpgates:
		if jumpgate.linkedstar == old_star:
			incoming_jumpgate = jumpgate
			break
	# Position player at the incoming jumpgate and set velocity
	if incoming_jumpgate:
		player_ship.position = incoming_jumpgate.position
		var speed = player_ship.velocity.length()
		if speed == 0:
			speed = 100  # default speed if stationary
		player_ship.velocity = -incoming_jumpgate.position.normalized() * speed
	else:
		# Fallback if no incoming jumpgate found
		player_ship.position = Vector2(200, 300)
		player_ship.velocity = Vector2(0, 0)
	# Emit signal to update starmap display
	emit_signal("star_changed", current_star)
	# Update nebula color to match star class
	nebula.modulate = starmap_display.get_star_color(current_star.starclass)
	# Set jump cooldown to prevent immediate re-jump
	jump_cooldown = 2.0
	# Respawn AI ships
	spawn_ai_ships()
