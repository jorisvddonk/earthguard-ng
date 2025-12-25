extends "res://src/BaseAutopilot.gd"

class_name AutopilotV2

var PIDController = load("res://src/PIDController.gd")
var Ship = load("res://src/Ship.gd")

const OFFSET_ALLOWED = 0.0872664626 # 5 degrees
const OFFSET_ALLOWED_BACKWARDS = 0.436332313 # 25 degrees

func _init(ship_node: Ship, options: Dictionary = {}):
	super._init(ship_node, options)
	self.controllers.posXPID = PIDController.new(-0.45, -0.0, -80, -10, 10, -10, 10)
	self.controllers.posYPID = PIDController.new(-0.45, -0.0, -80, -10, 10, -10, 10)

func tick(delta):
	var task = get_task()
	var target = get_target()
	
	var complete_func = func():
		emit_signal("complete")
	
	if task.type == Task.TaskType.IDLE or (target and target.type == Target.TargetType.LOST):
		return
	
	if task.type == Task.TaskType.HALT:
		var complete_halt = func():
			emit_signal("complete")
			GlobalSignals.debuglog.emit("Completing halt....")
			var t = ship.subsystems.ai.create_task(Task.TaskType.IDLE, Task.Goal.IDLE)
			ship.subsystems.ai.set_task(t)
		brake(complete_halt, delta)
		return
	
	var targetpos = target.get_target_position()
	if targetpos == null:
		return
	
	if task.type in [Task.TaskType.ATTACK, Task.TaskType.MOVE, Task.TaskType.FOLLOW]:
		move_to(targetpos, delta)
		if task.type == Task.TaskType.ATTACK:
			ship.maybe_fire()
		
		if task.type == Task.TaskType.MOVE and targetpos.distance_to(ship.position) < 50 and ship.velocity.length() < 0.75:
			complete_func.call()

func move_to(targetpos: Vector2, delta):
	var pos_vec_error = targetpos - ship.position
	var x_error = pos_vec_error.x
	var y_error = pos_vec_error.y
	self.controllers.posXPID.setError(x_error)
	self.controllers.posYPID.setError(y_error)
	var x_thrust = -self.controllers.posXPID.step()
	var y_thrust = -self.controllers.posYPID.step()
	
	var thrust_vec = Vector2(x_thrust, y_thrust)
	var sign_ = 1
	var thrust_angle = Vector2.UP.rotated(ship.rotation).angle_to(thrust_vec)
	
	if thrust_vec.length() > 0:
		if thrust_angle != NAN:
			if thrust_angle < PI - OFFSET_ALLOWED_BACKWARDS and thrust_angle > -PI + OFFSET_ALLOWED_BACKWARDS:
				ship.rotate_(thrust_angle)
			else:
				sign_ = -1
				if thrust_angle > 0:
					thrust_angle = -(PI - thrust_angle)
				else:
					thrust_angle = -(-PI + thrust_angle)
				ship.rotate_(thrust_angle)
	
		if thrust_angle < OFFSET_ALLOWED and thrust_angle > -OFFSET_ALLOWED:
			var actual_thrust = clamp(thrust_vec.length() * sign_ * 500, -1, 1)
			self.state.lthrust = actual_thrust
			ship.thrust(actual_thrust, delta)
	
	self.state.x_thrust = x_thrust
	self.state.y_thrust = y_thrust

func brake(on_complete: Callable, delta):
	var thrust_vec = ship.velocity.rotated(PI)
	var thrust_angle = Vector2.UP.rotated(ship.rotation).angle_to(thrust_vec)
	ship.rotate_(thrust_angle)
	thrust_angle = Vector2.UP.rotated(ship.rotation).angle_to(thrust_vec)  # recalculate after rotation
	
	if thrust_angle < OFFSET_ALLOWED and thrust_angle > -OFFSET_ALLOWED:
		var act_thrust = clamp(thrust_vec.length() * 500, -1, 1)
		self.state.lthrust = act_thrust
		ship.thrust(act_thrust, delta)
	
	if ship.velocity.length() < 0.9:
		on_complete.call()
