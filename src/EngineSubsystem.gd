extends "res://src/ShipSubsystem.gd"

class_name EngineSubsystem

var can_reverse: bool
var thrust_vector: Vector2
var power: float

func _init(ship_node: Node, options: Dictionary = {}):
	super._init(ship_node)
	options = options.duplicate(true)
	options.merge({
		"power": 0.04,
		"can_reverse": true
	}, true)
	self.subsystem_type = "engine"
	self.power = options.power
	self.can_reverse = options.can_reverse
	self.thrust_vector = Vector2(self.power, 0)

func tick(delta):
	pass