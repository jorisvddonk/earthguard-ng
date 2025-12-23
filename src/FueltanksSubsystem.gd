extends "res://src/ShipSubsystem.gd"

class_name FueltanksSubsystem

var fueltanks: Array

func _init(ship_node: Node, options: Dictionary = {}):
	super._init(ship_node)
	options = options.duplicate(true)
	options.merge({
		"name": "Awesome Fueltank",
		"capacity": 500,
		"content": 500
	}, true)
	self.subsystem_type = "fueltanks"
	self.fueltanks = [{
		"name": options.name,
		"capacity": options.capacity,
		"content": options.content
	}]

func get_fuel_remaining() -> float:
	var total = 0.0
	for tank in fueltanks:
		total += tank.content
	return total

func consume_fuel(amount: float) -> bool:
	for tank in fueltanks:
		if tank.content >= amount:
			tank.content -= amount
			return true
	return false

func tick(delta):
	pass