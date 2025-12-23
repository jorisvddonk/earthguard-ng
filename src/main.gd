extends Node2D

var Bullet = load("res://src/Bullet.tscn")
var Starmap = load("res://src/Starmap.gd")
var Planet = load("res://src/Planet.gd")
var Jumpgate = load("res://src/Jumpgate.gd")
var Ship = load("res://src/Ship.tscn")

var starmap
var current_star
var player_ship

func _ready():
	# Create starmap
	starmap = Starmap.new()
	current_star = starmap.stars[0]
	
	# Add planets and jumpgates
	add_planets_and_jumpgates()
	
	# Set up player ship
	player_ship = $PlayerShip
	player_ship.position = Vector2(200, 300)
	
	# Connect shooting
	player_ship.connect("shoot", Callable(self, "_on_Ship_shoot").bind(null, player_ship))
	
	# Spawn AI ships
	spawn_ai_ships()
	
	# Set up camera
	var camera = Camera2D.new()
	player_ship.add_child(camera)
	camera.make_current()

func add_planets_and_jumpgates():
	for planet in current_star.planets:
		add_child(planet)
	for jumpgate in current_star.jumpgates:
		add_child(jumpgate)

func spawn_ai_ships():
	for i in range(30):
		spawn_random_ship()

func spawn_random_ship():
	var factions = ["Civilians", "Civilians", "Civilians", "Pirates", "Police", "Police", "AnnoyingFan"]
	var faction = factions[randi() % factions.size()]
	
	var ship_scene = Ship.instantiate()
	ship_scene.position = Vector2(randf_range(-750, 750), randf_range(-750, 750))
	ship_scene.velocity = Vector2(randf_range(-1.5, 3.5), randf_range(-1.5, 3.5))
	
	add_child(ship_scene)
	
	# Set faction and AI task
	# For simplicity, set a basic task
	var ai = ship_scene.get_subsystems().ai
	var task = Task.new(Task.TaskType.IDLE)
	ai.set_task(task)
	
	ship_scene.connect("shoot", Callable(self, "_on_Ship_shoot").bind(ship_scene))

func _on_Ship_shoot(targetpos, ship):
	var bullet = Bullet.instantiate()
	var rot = ship.rotation
	if targetpos != null:
		rot = Vector2.UP.angle_to(targetpos - ship.position)
	bullet.set_velocity(ship.velocity + Vector2(0, -300).rotated(rot))
	bullet.position = ship.position
	bullet.rotation = ship.rotation
	bullet.shooter = ship  # Set the shooter for collision
	add_child(bullet)

func _physics_process(delta):
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
