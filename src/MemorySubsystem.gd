extends "res://src/ShipSubsystem.gd"

class_name MemorySubsystem

enum MessageType {
	TAKEN_DAMAGE
}

var deque: Array
var deque_index_of_last: int
var limit: int

func _init(ship_node: Node, options: Dictionary = {}):
	super._init(ship_node)
	options = options.duplicate(true)
	options.merge({
		"limit": 100
	}, true)
	self.subsystem_type = "memory"
	self.deque = []
	self.deque_index_of_last = -1
	self.limit = options.limit

func push(type: MessageType, data):
	if type == null or data == null:
		push_error("Missing type or data")
		return
	var message = {
		"type": type,
		"data": data
	}
	self.deque.append(message)
	self.deque_index_of_last += 1
	if self.deque.size() > self.limit:
		remove_oldest()

func read(index: int, callback: Callable):
	var i = self.deque_index_of_last - index
	if i >= 0 and i < self.deque.size():
		callback.call(index, self.deque[i])

func read_range(first: int, last: int, callback: Callable):
	for idx in range(first, last):
		read(idx, callback)

func remove_oldest():
	if self.deque.size() > 0:
		self.deque.pop_front()

func get_oldest_index() -> int:
	return self.deque_index_of_last - self.deque.size() + 1

func get_newest_index() -> int:
	return self.deque_index_of_last