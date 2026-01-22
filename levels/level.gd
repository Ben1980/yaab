extends Node2D


@export var enemy_count: int = 5
@export var color_transition_duration: float = 0.75


const ENEMY_SCENE: PackedScene = preload("res://characters/enemies/enemy.tscn")


@onready var game_over_screen: Control = $GameOverLayer/GameOverScreen
@onready var restart_button: Button = $GameOverLayer/GameOverScreen/CenterContainer/VBoxContainer/Restart
@onready var quit_button: Button = $GameOverLayer/GameOverScreen/CenterContainer/VBoxContainer/Quit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("spawn_enemies")


func is_position_valid(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1  # Match physics_layer_0
	query.collide_with_bodies = true
	return space_state.intersect_point(query).is_empty()


func spawn_enemies() -> void:
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
			var enemy = ENEMY_SCENE.instantiate()
			enemy.position = spawn_pos
			add_child(enemy)
			spawned += 1


func _on_player_game_over() -> void:
	game_over_screen.show()
	restart_button.hide()
	quit_button.hide()
	get_tree().paused = true
	
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($GameOverLayer/GameOverScreen/ColorRect, "modulate",  Color(0,0,0, 0.7), 0)
	tween.tween_property($GameOverLayer/GameOverScreen/ColorRect, "modulate",  Color(0.5,0,0, 0.8), color_transition_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(restart_button.show).set_delay(1)
	tween.tween_callback(quit_button.show)


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	pass # Replace with function body.
