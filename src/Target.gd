extends RefCounted

class_name Target

enum TargetType {
	SHIP,
	GAMEOBJECT,
	POSITION,
	LOST
}

var type: TargetType
var tgt

func _init(target_type: TargetType, target):
	self.type = target_type
	self.tgt = target

func get_game_object():
	if self.type == TargetType.GAMEOBJECT or self.type == TargetType.SHIP:
		# Assume objectRegistry is global or something
		# For now, return tgt as is
		return self.tgt
	else:
		return null

func get_target_position():
	if self.type == TargetType.GAMEOBJECT or self.type == TargetType.SHIP:
		var obj = get_game_object()
		if obj != null:
			return obj.position
		else:
			return TargetType.LOST
	elif self.tgt is Vector2:
		return self.tgt
	elif self.type == TargetType.LOST:
		return self.type
	else:
		return null