extends Node2D

@export var enemy_count: int = 5
@export var color_transition_duration: float = 0.75
@export var safe_radius: float = 250

var query: PhysicsPointQueryParameters2D = null

const ENEMY_SCENE: PackedScene = preload("res://characters/enemies/enemy.tscn")

@onready var game_over_screen: Control = $GameOverLayer/GameOverScreen
@onready var restart_button: Button = $GameOverLayer/GameOverScreen/CenterContainer/VBoxContainer/Restart
@onready var quit_button: Button = $GameOverLayer/GameOverScreen/CenterContainer/VBoxContainer/Quit
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	query = PhysicsPointQueryParameters2D.new()
	call_deferred("spawn_enemies")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		_on_quit_pressed()

func is_position_valid(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	if query:
		query.position = pos
		query.collision_mask = 1 
		query.collide_with_bodies = true
	else:
		return false
	
	if not space_state.intersect_point(query).is_empty():
		return false
	if is_instance_valid(player):
		var distance_to_player = query.position.distance_to(player.global_position)
		return distance_to_player > safe_radius
	
	return false

func spawn_enemies() -> void:
	var spawned = 0
	var max_attempts = enemy_count * 20
	
	for attempt in range(max_attempts):
		if spawned >= enemy_count:
			break
		
		if spawn_single_enemy():
			spawned += 1

func spawn_single_enemy() -> bool:
	var floor_layer: TileMapLayer = $Floor
	var used_cells = floor_layer.get_used_cells()
	
	for attempt in range(20):
		var cell = used_cells[randi() % used_cells.size()]
		var tile_center = floor_layer.map_to_local(cell)
		var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		var spawn_pos = tile_center + offset
		
		if is_position_valid(spawn_pos):
			var enemy = ENEMY_SCENE.instantiate()
			enemy.position = spawn_pos
			add_child(enemy)
			enemy.enemy_died.connect(_on_enemy_died)
			return true
	
	return false

func _on_enemy_died() -> void:
	call_deferred("spawn_single_enemy")

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
	tween.tween_callback(restart_button.grab_focus)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = 'https://yaab.online'")
	else:
		get_tree().quit()
