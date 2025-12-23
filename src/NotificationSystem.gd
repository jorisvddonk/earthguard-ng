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
	update_display()

func pop(index: int):
	if index >= 0 and index < notifications.size():
		notifications.remove_at(index)
		update_display()

func update_display():
	# Clear existing children
	for child in notification_bar.get_children():
		child.queue_free()
	
	# Add new notification buttons (newest first for right alignment)
	for i in range(notifications.size()-1, -1, -1):
		var notif = notifications[i]
		var button = TextureButton.new()
		button.texture_normal = create_circle_texture(get_color_for_type(notif.type))
		button.custom_minimum_size = Vector2(30, 30)
		button.connect("mouse_entered", Callable(self, "_on_notification_mouse_entered").bind(notif.message))
		button.connect("mouse_exited", Callable(self, "_on_notification_mouse_exited"))
		button.connect("pressed", Callable(self, "_on_notification_pressed").bind(i))
		notification_bar.add_child(button)

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

func _on_notification_pressed(index: int):
	bubble_label.visible = false
	pop(index)

func _on_timer_timeout():
	notif_count += 1
	var types = [NotificationType.ERROR, NotificationType.SHIP_DESTROYED, NotificationType.COMMUNICATIONS]
	var type = types[notif_count % 3]
	push(type, "Notification " + str(notif_count))
