extends Sprite2D

@export var fade_duration: float = 1.0 

@export var center_shade: Color = Color(0.196, 0.196, 0.196, 1.0)
@export var side_shade: Color = Color(0.392, 0.392, 0.392, 1.0)
@export var corner_shade: Color = Color(0.0, 0.0, 0.0, 0.0)

@onready var lifetime: Timer = $Timer 

func _ready() -> void:
	var image = Image.create(3, 3, false, Image.FORMAT_RGBA8)
	image.set_pixel(1, 1, center_shade)
	
	image.set_pixel(1, 0, side_shade)
	image.set_pixel(0, 1, side_shade)
	image.set_pixel(2, 1, side_shade)
	image.set_pixel(1, 2, side_shade)
	
	image.set_pixel(0, 0, corner_shade)
	image.set_pixel(2, 0, corner_shade)
	image.set_pixel(0, 2, corner_shade)
	image.set_pixel(2, 2, corner_shade)
	
	texture = ImageTexture.create_from_image(image)
	
	lifetime.start()

func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(queue_free)
