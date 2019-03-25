extends Sprite

var velocity = Vector2(0,0)
export var acceleration = 230
export var rotationSpeed = 3
export var maxSpeed = 300

func _process(delta):
	if Input.is_key_pressed(KEY_W):
		velocity += Vector2(0, -acceleration*delta).rotated(rotation)
	if Input.is_key_pressed(KEY_A):
		rotation -= rotationSpeed*delta
	if Input.is_key_pressed(KEY_D):
		rotation += rotationSpeed*delta
		
	position += velocity * delta
