extends Node2D

signal shoot

var Bullet = load("res://Bullet.tscn")
var PIDController = load("res://PIDController.gd")

var xpid = PIDController.new(-0.45, -0.2, -80, -10, 10, -10, 10)
var ypid = PIDController.new(-0.45, -0.2, -80, -10, 10, -10, 10)
const OFFSET_ALLOWED = 0.0872664626 # 5 degrees
const OFFSET_ALLOWED_BACKWARDS = 0.436332313 # 25 degrees
const SHOOT_OFFSET_ALLOWED = OFFSET_ALLOWED * 0.1
var thrust_vec = null
var target = null

var velocity = Vector2(0,0)
@export var acceleration = 230
@export var rotationSpeed = 3
@export var maxSpeed = 300

func _ready():
	self.connect("shoot", Callable(self, "_on_shoot"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player : Node2D = self.owner.get_node("PlayerShip")
	var possible_bullet_velocity = velocity.length() + 300
	
	target = player.position
	var tgtError = target - position
	
	target = self.intercept(position, possible_bullet_velocity, player.position, player.velocity)
	
	tgtError = target - position	
	xpid.setError(tgtError.x)
	ypid.setError(tgtError.y)
	xpid.step()
	ypid.step()
	
	thrust_vec = Vector2(-xpid.getError(), -ypid.getError())
	var sign_ = 1
	var thrust_angle = Vector2.UP.rotated(rotation).angle_to(thrust_vec)
	
	# If we have a large thrust vector (large error):
	if thrust_vec.length() > 0:
		# Turn towards x_thrust/y_thrust
		if thrust_angle != NAN:
			if thrust_angle < PI - OFFSET_ALLOWED_BACKWARDS && thrust_angle > -PI + OFFSET_ALLOWED_BACKWARDS:
				self.rotate_(thrust_angle)
			else:
				sign_ = -1
				if thrust_angle > 0:
					thrust_angle = -(PI - thrust_angle)
				elif thrust_angle < 0:
					thrust_angle = -(-PI + thrust_angle)
				self.rotate_(thrust_angle)
	
		# Thrust if we're aligned correctly;
		if thrust_angle < OFFSET_ALLOWED && thrust_angle > -OFFSET_ALLOWED:
			var actual_thrust = clamp(thrust_vec.length() * sign_ * 500, -1, 1)
			self.thrust(actual_thrust, delta) # todo lower/max thrust?

	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed
		
	position += velocity * delta
	
	emit_signal("shoot", target) # TODO: figure out _when_ to shoot

	update() # redraw

func thrust(vel, delta):
	#pass # temporarily disabled
	velocity += Vector2(0, -acceleration*delta*vel).rotated(rotation)

func rotate_(angle):
	rotation += clamp(angle, -PI * 0.01, PI * 0.01)

func _draw():
	var inv = get_global_transform().inverse()
	if thrust_vec != null:
		draw_set_transform(Vector2.ZERO, inv.get_rotation(), Vector2.ONE) # undo global rotation
		draw_line(Vector2.ZERO, thrust_vec, Color.RED, 2.0)
	if target != null:
		draw_set_transform(inv.origin, inv.get_rotation(), Vector2.ONE) # undo global rotation and position
		draw_circle(target, 10, Color.RED)

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
