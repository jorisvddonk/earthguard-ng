extends Sprite

var life = 1
var velocity = Vector2(0,-300)

func _ready():
	pass # Replace with function body.

func _process(delta):
	life -= delta
	if (life < 0):
		self.queue_free()
	position += velocity * delta

func set_velocity(vel):
	velocity = vel