extends Node2D

class_name Ship

signal shoot
signal hit

const Inventory = preload("res://src/Inventory.gd")
var Bullet = load("res://src/Bullet.tscn")
var PIDController = load("res://src/PIDController.gd")

const SHOOT_OFFSET_ALLOWED = 0.00872664626 # 0.5 degrees
var subsystems: Dictionary
var _objid = randi()
var faction = ""

var velocity = Vector2(0,0)
@export var acceleration = 230
@export var rotationSpeed = 3
@export var maxSpeed = 300
@export var cargo_capacity: int = 100

var inventory: Inventory

func _ready():
	self.connect("shoot", Callable(self, "_on_shoot"))
	
	# Initialize subsystems
	subsystems.memory = MemorySubsystem.new(self)
	subsystems.ai = AISubsystem.new(self)
	subsystems.autopilot = AutopilotV2.new(self)
	subsystems.hull = HullSubsystem.new(self)
	subsystems.engine = EngineSubsystem.new(self)
	subsystems.fueltanks = FueltanksSubsystem.new(self)
	subsystems.sensor = SensorSubsystem.new(self)
	
	# Initialize inventory
	inventory = Inventory.new()
	inventory.add_item("Credits", 1000, 1.0)  # Starting credits

func get_subsystems() -> Dictionary:
	return subsystems

func maybe_fire():
	var target = subsystems.ai.get_target()
	if target:
		var target_pos = target.get_target_position()
		if target_pos is Vector2:
			var angle_to_target = position.angle_to_point(target_pos)
			var angle_diff = abs(angle_to_target - rotation)
			if angle_diff < SHOOT_OFFSET_ALLOWED:
				emit_signal("shoot", target_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Tick subsystems first
	for subsystem in subsystems.values():
		if subsystem.has_method("tick"):
			subsystem.tick(delta)
	
	# Apply velocity
	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed
		
	position += velocity * delta
	
	# Handle shooting
	var target = subsystems.ai.get_target()
	if target:
		var target_pos = target.get_target_position()
		if target_pos is Vector2:
			var angle_to_target = position.angle_to_point(target_pos)
			var angle_diff = abs(angle_to_target - rotation)
			if angle_diff < SHOOT_OFFSET_ALLOWED:
				emit_signal("shoot", target_pos)
	
	queue_redraw()


func thrust(vel, delta):
	#pass # temporarily disabled
	velocity += Vector2(0, -acceleration*delta*vel).rotated(rotation)

func rotate_(angle):
	rotation += clamp(angle, -PI * 0.01, PI * 0.01)

func _draw():
	# Drawing handled by subsystems if needed
	pass

func intercept(shooter: Vector2, bullet_speed: float, target: Vector2, target_velocity: Vector2):
	var displacement = shooter - target
	var a = bullet_speed * bullet_speed - target_velocity.dot(target_velocity)
	var b = -2 * target_velocity.dot(displacement)
	var c = -displacement.dot(displacement)
	var lrg = largest_root_of_quadratic_equation(a, b, c)
	if lrg == NAN or lrg == null:
		return null
	else:
		var interception_world = target + (target_velocity * lrg)
		return interception_world

func largest_root_of_quadratic_equation(a, b, c):
	return (b + sqrt(b * b - 4 * a * c)) / (2 * a)

func buy_from_planet(planet: Planet, category: String, amount: int) -> bool:
	if not Inventory.CATEGORIES.has(category) or category == "Credits":
		return false
	var available = planet.supplies.get(category, 0)
	if available < amount:
		return false
	if not inventory.can_add(category, amount, cargo_capacity):
		return false
	var prices = planet.prices.get(category, {})
	var price = prices.get("buy_price", 0)
	var cost = price * amount
	if inventory.get_amount("Credits") < cost:
		return false
	# Pay
	inventory.remove_item("Credits", cost)
	planet.supplies["Credits"] = planet.supplies.get("Credits", 0) + cost
	# Transfer item
	planet.supplies[category] -= amount
	inventory.add_item(category, amount, price)
	GlobalSignals.debuglog.emit("Bought %d %s for %d credits from %s" % [amount, category, cost, str(planet)])
	return true

func sell_to_planet(planet: Planet, category: String, amount: int) -> bool:
	if not Inventory.CATEGORIES.has(category) or category == "Credits":
		return false
	if inventory.get_amount(category) < amount:
		return false
	var prices = planet.prices.get(category, {})
	var price = prices.get("sell_price", 0)
	var revenue = price * amount
	# Transfer item
	inventory.remove_item(category, amount)
	planet.supplies[category] = planet.supplies.get(category, 0) + amount
	# Receive credits
	inventory.add_item("Credits", revenue, 1.0)
	planet.supplies["Credits"] = planet.supplies.get("Credits", 0) - revenue
	GlobalSignals.debuglog.emit("Sold %d %s for %d credits at %s" % [amount, category, revenue, str(planet)])
	return true

func get_inventory() -> Inventory:
	return inventory

func request_market_data_from_planet() -> Dictionary:
	# Simulate radio call: get market data from all planets
	var main = get_tree().root
	if main is Window:
		for child in main.get_children():
			if child is Node2D:
				main = child
				break
	var planets = main.current_star.planets
	var market_data = {}
	for planet in planets:
		market_data[planet] = {
			"prices": planet.get_prices(),
			"supplies": planet.get_supplies()
		}
	return market_data
	
func get_task() -> Task:
	return subsystems.ai.get_task()
