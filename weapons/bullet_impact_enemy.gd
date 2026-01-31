extends GPUParticles2D

var direction: Vector2

func _ready() -> void:
	var image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 1.0))
	texture = ImageTexture.create_from_image(image)
	process_material = process_material.duplicate()
	
	process_material.direction = Vector3(-self.direction.x, -self.direction.y, 0)
	
	call_deferred("emit")

func _on_finished() -> void:
	queue_free()

func set_direction(bullet_direction: Vector2) -> void:
	direction = bullet_direction

func emit() -> void:
	emitting = true
