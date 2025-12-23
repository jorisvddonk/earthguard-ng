extends Node2D

signal shoot
signal hit

var Bullet = load("res://src/Bullet.tscn")
var PIDController = load("res://src/PIDController.gd")

const SHOOT_OFFSET_ALLOWED = 0.00872664626 # 0.5 degrees
var subsystems: Dictionary

var velocity = Vector2(0,0)
@export var acceleration = 230
@export var rotationSpeed = 3
@export var maxSpeed = 300

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
			subsystem.tick()
	
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
