extends Area2D

@export var speed: float = 800
@export var bullet_width: int = 1
@export var bullet_length: int = 30
@export var bullet_front_color: Color = Color(1.0, 0.88, 0.75, 1.0)
@export var bullet_mid_color: Color = Color(1.0, 0.659, 0.36, 0.75)
@export var bullet_back_color: Color = Color(0.86, 0.393, 0.06, 0.1)

var direction: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const BULLET_IMPACT_WALL_SCENE: PackedScene = preload("res://weapons/bullet_impact_wall.tscn")
const BULLET_IMPACT_ENEMY_SCENE: PackedScene = preload("res://weapons/bullet_impact_enemy.tscn")

func _ready() -> void:
	setup_texture()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("hit"):
		sheed_blood()
		body.hit()
	else:
		var wall_normal = get_wall_normal()
		spawn_impact(wall_normal)
	
	queue_free()

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

func spawn_impact(wall_normal: Vector2) -> void:
	var wall_impact = BULLET_IMPACT_WALL_SCENE.instantiate()
	var tip_offset = direction.normalized() * (bullet_length / 2.0)
	wall_impact.global_position = global_position + tip_offset
	wall_impact.rotation = wall_normal.angle()
	get_parent().add_child(wall_impact)

func get_wall_normal() -> Vector2:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		  global_position,
		  global_position + direction * 50.0  # Ray ahead of bullet
	)
	query.exclude = [self]
	query.collision_mask = collision_mask
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.normal
	else:
		return -direction

func sheed_blood() -> void:
	var enemy_impact = BULLET_IMPACT_ENEMY_SCENE.instantiate()
	var tip_offset = direction.normalized() * (bullet_length / 2.0)
	enemy_impact.global_position = global_position + tip_offset
	get_parent().add_child(enemy_impact)
