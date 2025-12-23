extends RefCounted

class_name Task

var Target = load("res://src/Target.gd")

enum TaskType {
	FOLLOW,
	ATTACK,
	MOVE,
	IDLE,
	HALT
}

var target
var type: TaskType

func _init(task_type: TaskType, task_target = null):
	self.type = task_type
	self.target = task_target