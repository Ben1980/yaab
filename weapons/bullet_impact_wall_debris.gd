extends GPUParticles2D

func _ready() -> void:
	var image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 1.0))
	texture = ImageTexture.create_from_image(image)
	process_material = process_material.duplicate()
	
	emitting = true

func _on_finished() -> void:
	queue_free()
