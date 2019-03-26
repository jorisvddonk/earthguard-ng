extends Node2D

var Bullet = load("res://Bullet.tscn")

func _ready():
	$PlayerShip.connect("shoot", self, "_on_Player_shoot")

func _on_Player_shoot():
	var bullet = Bullet.instance()
	bullet.set_velocity($PlayerShip.velocity + Vector2(0, -300).rotated($PlayerShip.rotation))
	bullet.position = $PlayerShip.position
	bullet.rotation = $PlayerShip.rotation
	add_child(bullet)