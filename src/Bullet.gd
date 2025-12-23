extends Sprite2D
class_name Bullet

var life = 10
var velocity = Vector2(0,-300)
var shooter = null

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	life -= delta
	if (life < 0):
		self.queue_free()
	position += velocity * delta

func set_velocity(vel):
	velocity = vel
