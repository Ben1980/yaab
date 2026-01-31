extends Area2D

@export var speed: float = 800
@export var bullet_width: int = 1
@export var bullet_length: int = 30
@export var bullet_front_color: Color = Color(1.0, 0.88, 0.75, 1.0)
@export var bullet_mid_color: Color = Color(1.0, 0.659, 0.36, 0.75)
@export var bullet_back_color: Color = Color(0.86, 0.393, 0.06, 0.1)

var direction: Vector2 = Vector2.ZERO
var shape_cast: ShapeCast2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const BULLET_IMPACT_WALL_SCENE: PackedScene = preload("res://weapons/bullet_impact_wall.tscn")
const BULLET_IMPACT_ENEMY_SCENE: PackedScene = preload("res://weapons/bullet_impact_enemy.tscn")

func _ready() -> void:
	setup_texture()
	setup_shape_cast()

func _physics_process(delta: float) -> void:
	#position += direction * speed * delta
	var movement_vector = direction * speed * delta
	
	shape_cast.target_position = movement_vector
	shape_cast.force_shapecast_update()
	
	if shape_cast.is_colliding():
		var safe_fraction = shape_cast.get_closest_collision_safe_fraction()
		position += movement_vector * safe_fraction
		
		var collider = shape_cast.get_collider(0)
		var hit_normal = shape_cast.get_collision_normal(0)
		
		if collider.is_in_group("enemy") and collider.has_method("hit"):
			enemy_impact()
			collider.hit()
		else:
			wall_impact(hit_normal)
			
		queue_free()
	else:
		position += movement_vector

func setup_texture() -> void:
	var image = Image.create(bullet_width, bullet_length, false, Image.FORMAT_RGBA8)
	
	var gradient = Gradient.new()
	gradient.set_color(1, bullet_front_color)
	gradient.set_color(0, bullet_back_color)
	gradient.add_point(0.75, bullet_mid_color)
	
	for y in range(bullet_length):
		var t = float(y) / float(bullet_length - 1)
		var color = gradient.sample(t)
		for x in range(bullet_width):
			image.set_pixel(x, y, color)
			
	sprite.texture = ImageTexture.create_from_image(image)
	
	collision_shape.shape.size = Vector2(bullet_width, bullet_length)

func wall_impact(wall_normal: Vector2) -> void:
	var wall_impact_instance = BULLET_IMPACT_WALL_SCENE.instantiate()
	var tip_offset = direction.normalized() * (bullet_length / 2.0)
	wall_impact_instance.global_position = global_position + tip_offset
	wall_impact_instance.rotation = wall_normal.angle()
	get_parent().add_child(wall_impact_instance)

func enemy_impact() -> void:
	var enemy_impact_instance = BULLET_IMPACT_ENEMY_SCENE.instantiate()
	enemy_impact_instance.set_direction(self.direction)
	var tip_offset = direction.normalized() * (bullet_length / 2.0)
	enemy_impact_instance.global_position = global_position + tip_offset
	get_parent().add_child(enemy_impact_instance)

func setup_shape_cast() -> void:
	shape_cast = ShapeCast2D.new()
	var cast_shape = RectangleShape2D.new()
	
	cast_shape.size = Vector2(bullet_width, bullet_length)
	shape_cast.shape = cast_shape
	
	shape_cast.collision_mask = self.collision_mask
	shape_cast.enabled = true
	
	add_child(shape_cast)
