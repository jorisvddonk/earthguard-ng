extends "res://src/ShipSubsystem.gd"

class_name HullSubsystem

var integrity: float
var max_integrity: float

func _init(ship_node: Node, options: Dictionary = {}):
	super._init(ship_node)
	options = options.duplicate(true)
	options.merge({
		"max_integrity": 1000
	}, true)
	self.subsystem_type = "hull"
	self.integrity = options.max_integrity
	self.max_integrity = options.max_integrity
	# Connect to ship's hit signal
	if ship_node.has_signal("hit"):
		ship_node.connect("hit", Callable(self, "_on_hit"))

func _on_hit(damage: float):
	take_damage(damage)

func take_damage(amount: float):
	self.integrity -= amount