extends Node2D

@export var enemy_scene: PackedScene
@export var enemy_count: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_scene = preload("res://enemy.tscn")
	call_deferred("spawn_enemies")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func is_position_valid(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1  # Match physics_layer_0
	query.collide_with_bodies = true
	return space_state.intersect_point(query).is_empty()


func spawn_enemies():
	var floor_layer: TileMapLayer = $Floor
	var used_cells = floor_layer.get_used_cells()
	
	var spawned = 0
	var max_attempts = enemy_count * 20
	
	for attempt in range(max_attempts):
		if spawned >= enemy_count:
			break
			
		var cell = used_cells[randi() % used_cells.size()]
		var tile_center = floor_layer.map_to_local(cell)
		var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		var spawn_pos = tile_center + offset
		
		if is_position_valid(spawn_pos):
			var enemy = enemy_scene.instantiate()
			enemy.position = spawn_pos
			add_child(enemy)
			spawned += 1
