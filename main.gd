extends Node2D

var Bullet = load("res://Bullet.tscn")

func _ready():
	$PlayerShip.connect("shoot", Callable(self, "_on_Ship_shoot").bind(null, $PlayerShip))
	$Ship.connect("shoot", Callable(self, "_on_Ship_shoot").bind($Ship))

func _on_Ship_shoot(targetpos, ship):
	var bullet = Bullet.instantiate()
	var rot = ship.rotation
	if targetpos != null:
		rot = Vector2.UP.angle_to(targetpos - ship.position)
	bullet.set_velocity(ship.velocity + Vector2(0, -300).rotated(rot))
	bullet.position = ship.position
	bullet.rotation = ship.rotation
	add_child(bullet)
