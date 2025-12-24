extends "res://src/ShipSubsystem.gd"

class_name AISubsystem

signal target_lost

var Task = load("res://src/Task.gd")
var Target = load("res://src/Target.gd")
var MemoryReader = load("res://src/MemoryReader.gd")
var MemorySubsystem = load("res://src/MemorySubsystem.gd")

var task
var other_ships_hitting_me: Dictionary
var memory_reader

func _init(ship_node: Node, options: Dictionary = {}):
	super._init(ship_node)
	self.subsystem_type = "ai"
	self.task = create_task(Task.TaskType.IDLE, Task.Goal.IDLE)
	self.other_ships_hitting_me = {}
	
	var callbacks = {
		MemorySubsystem.MessageType.TAKEN_DAMAGE: Callable(self, "_on_taken_damage")
	}
	self.memory_reader = MemoryReader.new(ship_node, callbacks)

func tick(delta):
	super.tick(delta)
	
	if self.task and self.task.target:
		if (self.task.target.type == Target.TargetType.LOST or 
			(self.task.target.type == Target.TargetType.GAMEOBJECT and not self.task.target.get_game_object())):
			# Target lost
			emit_signal("target_lost")  # Emit signal or something
	
	# Other logic

func _on_taken_damage(data: Dictionary):
	var perpetrator_objid = data.perpetrator_objid
	var damage = data.damage
	var old_d = self.other_ships_hitting_me.get(perpetrator_objid, 0.0)
	var new_d = old_d + damage
	self.other_ships_hitting_me[perpetrator_objid] = new_d
	if old_d < 300 and new_d >= 300:
		# Assume objectRegistry
		var perpetrator = null  # get from registry
		if perpetrator:
			self.set_task(create_task(Task.TaskType.ATTACK, Task.Goal.DESTROY, perpetrator))
			# Notification

func get_target():
	return self.task.target

func get_task():
	return self.task

func set_task(new_task):
	if not new_task:
		push_error("Task is null!")
		return
	self.task = new_task
	# Emit signal

func clear_task():
	self.task = create_task(Task.TaskType.IDLE, Task.Goal.IDLE)

func create_task(task_type, goal, target = null):
	return Task.new(task_type, goal, target)
