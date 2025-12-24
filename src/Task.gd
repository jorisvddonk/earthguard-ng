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

enum Goal {
	DESTROY,
	TRADE,
	INVESTIGATE,
	ESCORT,
	IDLE,
	EXPLORE,
	COLLECT,
	SCAN,
	FLEE,
	UPGRADE_AND_REPAIR
}

var target
var type: TaskType
var goal: Goal

func _init(task_type: TaskType, task_goal: Goal, task_target = null):
	self.type = task_type
	self.goal = task_goal
	self.target = task_target
