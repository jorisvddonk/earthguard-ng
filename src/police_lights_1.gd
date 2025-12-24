extends Node2D

func _physics_process(delta):
	get_child(0).rotate(12 * delta)
	get_child(1).rotate(12 * delta)

func _enter_tree():
	var r = randf_range(0, PI)
	get_child(0).rotate(r)
	get_child(1).rotate(r)
