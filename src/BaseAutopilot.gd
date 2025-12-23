extends "res://src/ShipSubsystem.gd"

class_name BaseAutopilot

var Task = load("res://src/Task.gd")
var Target = load("res://src/Target.gd")

var controllers: Dictionary
var state: Dictionary

func _init(ship_node: Node, options: Dictionary = {}):
	super._init(ship_node)
	self.subsystem_type = "autopilot"
	self.controllers = {}
	self.state = {}
	# Connect to ai_target_changed if exists

func get_target():
	if ship.has_method("get_subsystems") and ship.get_subsystems().has("ai"):
		return ship.get_subsystems().ai.get_target()
	return null

func get_task():
	if ship.has_method("get_subsystems") and ship.get_subsystems().has("ai"):
		return ship.get_subsystems().ai.get_task()
	return create_task(Task.TaskType.IDLE)

func create_task(task_type, target = null):
	return Task.new(task_type, target)