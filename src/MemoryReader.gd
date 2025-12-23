extends Node

class_name MemoryReader

var ship: Node
var memory: Node
var callback_functions: Dictionary
var newest_index_read: int

func _init(ship_node: Node, callback_funcs: Dictionary, options: Dictionary = {}):
	self.ship = ship_node
	self.memory = null
	self.callback_functions = callback_funcs
	self.newest_index_read = -1

func tick():
	if self.memory == null:
		if ship.has_method("get_subsystems") and ship.get_subsystems().has("memory"):
			self.memory = ship.get_subsystems().memory
		return
	if self.newest_index_read < self.memory.get_newest_index():
		self.memory.read_range(
			self.newest_index_read + 1,
			self.memory.get_newest_index() + 1,
			Callable(self, "_on_read_message")
		)

func _on_read_message(index: int, message: Dictionary):
	self.newest_index_read = index
	if self.callback_functions.has(message.type):
		self.callback_functions[message.type].call(message.data)