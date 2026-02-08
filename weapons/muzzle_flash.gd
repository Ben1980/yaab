extends GPUParticles2D

@export var muzzle_flash_pattern: Array[int] = []
@export var bright_color: Color = Color(1.0, 1.0, 0.5, 1.0)
@export var medium_color: Color = Color(1.0, 0.5, 0.5, 1.0)
@export var dark_color: Color = Color(1.0, 0.5, 0.2, 0.8)
@export var bright_threshold: float
@export var medium_threshold: float

@onready var light: PointLight2D = $PointLight2D

func _ready() -> void:
	self.texture = create_flame_texture()
	
	var tween = create_tween()
	tween.tween_property(light, "energy", 0, lifetime).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	emitting = true

func _on_finished() -> void:
	queue_free()

func create_flame_texture() -> ImageTexture:
	#      **
	#     **** 
	#     **** 
	#   ********
	#   ********
	#  **********
	#  **********
	#    ******
	#     ****  
	var height = muzzle_flash_pattern.size()
	var width = muzzle_flash_pattern.max()
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	
	for y in range(0, height):
		var row_width = muzzle_flash_pattern[y]
		var start_x = (width - row_width) / 2
		
		for x in range(0, width):
			if x >= start_x && x < start_x + row_width:
				var center_x = (width-1) / 2.0
				var center_dist = abs(x - center_x) / ((width-1) / 2.0)
				var color = calculate_flame_color(center_dist, y, height)
				image.set_pixel(x, y, color)
			else:
				image.set_pixel(x, y, Color(0,0,0,0))
	
	return ImageTexture.create_from_image(image)

func calculate_flame_color(center_distance: float, y: float, height: float) -> Color:
	var vertical_factor = 1.0 - (y / height) * 0.3
	var horizontal_factor = 1.0 - center_distance * 0.4
	
	var brightness = vertical_factor * horizontal_factor
	
	if brightness > bright_threshold:
		return bright_color
	elif brightness > medium_threshold:
		return medium_color
	else:
		return dark_color

func get_length() -> int:
	return muzzle_flash_pattern.size() 
