extends "res://src/ShipSubsystem.gd"

class_name SensorSubsystem

enum MessageType {
	TAKEN_DAMAGE
}

func _init(ship_node: Node, options: Dictionary = {}):
	super._init(ship_node)
	options = options.duplicate(true)
	self.subsystem_type = "sensor"
	# Connect to ship's hit signal
	if ship_node.has_signal("hit"):
		ship_node.connect("hit", Callable(self, "_on_hit"))

func _on_hit(data: Dictionary):
	# Assume ship has subsystems.memory
	if ship.subsystems.has("memory"):
		ship.subsystems.memory.push(MessageType.TAKEN_DAMAGE, {
			"damage": data.damage,
			"perpetrator_objid": data.perpetrator._objid
		})
