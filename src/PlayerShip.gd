extends Sprite2D
signal shoot

const Inventory = preload("res://src/Inventory.gd")

var _objid = randi()
var faction = "Player"
var velocity = Vector2(0,0)
@export var acceleration = 230
@export var rotationSpeed = 3
@export var maxSpeed = 300
@export var cargo_capacity: int = 50

var inventory: Inventory

func _ready():
	inventory = Inventory.new()

func get_inventory() -> Inventory:
	return inventory

func _process(delta):
	if Input.is_key_pressed(KEY_W):
		velocity += Vector2(0, -acceleration*delta).rotated(rotation)
	if Input.is_key_pressed(KEY_A):
		rotation -= rotationSpeed*delta
	if Input.is_key_pressed(KEY_D):
		rotation += rotationSpeed*delta
	
	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed
		
	position += velocity * delta
	
	if Input.is_key_pressed(KEY_SPACE):
		emit_signal("shoot")
