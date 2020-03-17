extends Node2D

var PIDController = load("res://PIDController.gd")
var xpid = PIDController.new(-0.45, -0.2, -80, -10, 10, -10, 10)
var ypid = PIDController.new(-0.45, -0.2, -80, -10, 10, -10, 10)
const OFFSET_ALLOWED = 0.0872664626 # 5 degrees
const OFFSET_ALLOWED_BACKWARDS = 0.436332313 # 25 degrees

var velocity = Vector2(0,0)
export var acceleration = 230
export var rotationSpeed = 3
export var maxSpeed = 300

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player : Node2D = self.owner.get_node("PlayerShip")
	xpid.setError(player.position.x - position.x)
	ypid.setError(player.position.y - position.y)
	xpid.step()
	ypid.step()
	
	var thrust_vec = Vector2(-xpid.getError(), -ypid.getError())
	var sign_ = 1
	var thrust_angle = Vector2.UP.rotated(rotation).angle_to(thrust_vec)
	
	# If we have a large thrust vector (large error):
	if thrust_vec.length() > 0:
		# Turn towards x_thrust/y_thrust
		if thrust_angle != NAN:
			if thrust_angle < PI - OFFSET_ALLOWED_BACKWARDS &&	thrust_angle > -PI + OFFSET_ALLOWED_BACKWARDS:
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
	else:
		# If we have a small thrust vector, let's just point towards the enemy ship..
		# self.rotate(rot); # ?? todo re-add?
		pass

	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed
		
	position += velocity * delta

	#print(xpid.getError())

func thrust(vel, delta):
	velocity += Vector2(0, -acceleration*delta*vel).rotated(rotation)

func rotate_(angle):
	rotation += clamp(angle, -PI * 0.01, PI * 0.01)
