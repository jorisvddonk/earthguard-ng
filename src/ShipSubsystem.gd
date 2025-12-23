extends Node

class_name ShipSubsystem

var ship: Node
var subsystem_type: String

func _init(ship_node: Node):
	self.ship = ship_node
	self.subsystem_type = "generic_subsystem"

func tick():
	pass