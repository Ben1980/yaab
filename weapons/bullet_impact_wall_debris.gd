extends GPUParticles2D

@onready var light: PointLight2D = $PointLight2D

func _ready() -> void:
	var image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 1.0))
	texture = ImageTexture.create_from_image(image)
	process_material = process_material.duplicate()
	
	var tween = create_tween()
	tween.tween_property(light, "energy", 0, lifetime).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	emitting = true

func _on_finished() -> void:
	queue_free()
