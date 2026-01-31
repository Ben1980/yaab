extends RigidBody2D

@export var ejection_speed: float = 200.0
@export var fade_duration: float = 1.0 

var direction: Vector2 = Vector2.RIGHT

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var lifetime_timer: Timer = $Sprite2D/Lifetime

func _ready() -> void:
	setup_kinematic()
	setup_texture()
	lifetime_timer.start()

func setup_kinematic() -> void:
	var angle_variation = randf_range(-0.2, 0.2)
	direction = direction.rotated(angle_variation)
	
	linear_velocity = direction.normalized() * ejection_speed * randf_range(0.5, 1.5)
	angular_velocity = randf_range(-5, 5)

func setup_texture() -> void:
	var shell_width = 3
	var shell_hight = 7
	var image = Image.create(shell_width, shell_hight, false, Image.FORMAT_RGBA8)
	
	for x in range(0, shell_width):
		image.set_pixel(x, 0, Color(0.40, 0.32, 0.20));
	
	for y in range(1, shell_hight):
		image.set_pixel(0, y, Color(0.55, 0.45, 0.28));
		image.set_pixel(1, y, Color(0.72, 0.60, 0.38));
		image.set_pixel(2, y, Color(0.88, 0.78, 0.55));
	
	sprite.texture = ImageTexture.create_from_image(image)
	collision_shape.shape.size = Vector2(shell_width, shell_hight)

func _on_lifetime_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(queue_free)
