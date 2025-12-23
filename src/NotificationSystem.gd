extends Node

enum NotificationType {
	ERROR,
	SHIP_DESTROYED,
	COMMUNICATIONS
}

class Notification:
	var type: NotificationType
	var message: String
	var index: int
	
	func _init(t: NotificationType, msg: String):
		type = t
		message = msg

var notifications: Array[Notification] = []
var notification_index: int = 0
var notification_bar: HBoxContainer
var bubble_label: Label
var timer: Timer
var notif_count: int = 0
var buttons: Array[TextureButton] = []

func _ready():
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(timer)

func init(bar: HBoxContainer, bubble: Label):
	notification_bar = bar
	bubble_label = bubble
	bubble_label.z_index = 10
	bubble_label.visible = false
	timer.start()

func push(type: NotificationType, message: String):
	var notif = Notification.new(type, message)
	notif.index = notification_index
	notification_index += 1
	notifications.append(notif)
	
	# Create button
	var button = TextureButton.new()
	button.texture_normal = create_circle_texture(get_color_for_type(notif.type))
	button.custom_minimum_size = Vector2(30, 30)
	button.connect("mouse_entered", Callable(self, "_on_notification_mouse_entered").bind(notif.message))
	button.connect("mouse_exited", Callable(self, "_on_notification_mouse_exited"))
	button.connect("pressed", Callable(self, "_on_notification_pressed").bind(button))
	
	# Add to bar at front (rightmost if aligned right)
	notification_bar.add_child(button)
	notification_bar.move_child(button, 0)
	buttons.insert(0, button)
	
	# Animate in by moving the bar
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	button.modulate.a = 0
	notification_bar.position.x += 30 + 4  # shift bar right instantly
	tween.tween_property(button, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(notification_bar, "position:x", 0.0, 0.5)

func pop(index: int):
	if index < 0 or index >= notifications.size(): return
	var button_index = notifications.size() - 1 - index
	var button = buttons[button_index]
	notifications.remove_at(index)
	buttons.remove_at(button_index)
	
	# Animate out
	var tween = create_tween()
	tween.tween_property(button, "modulate:a", 0.0, 0.5).finished.connect(func(): button.queue_free())



func get_color_for_type(type: NotificationType) -> Color:
	match type:
		NotificationType.ERROR:
			return Color.RED
		NotificationType.SHIP_DESTROYED:
			return Color.ORANGE_RED
		NotificationType.COMMUNICATIONS:
			return Color.LIGHT_SKY_BLUE
		_:
			return Color.GRAY

func create_circle_texture(color: Color) -> Texture2D:
	var size = 30
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var center = Vector2(size/2, size/2)
	var radius = size/2
	for x in range(size):
		for y in range(size):
			var dist = center.distance_to(Vector2(x, y))
			if dist <= radius:
				image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

func _on_notification_mouse_entered(message: String):
	bubble_label.text = message
	bubble_label.visible = true

func _on_notification_mouse_exited():
	bubble_label.visible = false

func _on_notification_pressed(button: TextureButton):
	bubble_label.visible = false
	var button_index = buttons.find(button)
	if button_index == -1: return
	var notif_index = notifications.size() - 1 - button_index
	pop(notif_index)

func _on_timer_timeout():
	notif_count += 1
	var types = [NotificationType.ERROR, NotificationType.SHIP_DESTROYED, NotificationType.COMMUNICATIONS]
	var type = types[notif_count % 3]
	push(type, "Notification " + str(notif_count))
