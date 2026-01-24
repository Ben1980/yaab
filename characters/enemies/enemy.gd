extends CharacterBody2D


@export var patrol_speed: float = 30.0
@export var chase_speed: float = 60.0
@export var vision_range: float = 150.0
@export var direction_change_time: float = 2.0 


enum State { PATROL, CHASE }
var current_state: State = State.PATROL
var player: CharacterBody2D = null
var patrol_direction: Vector2 = Vector2.ZERO
var patrol_timer: float = 0.0
var last_known_player_pos: Vector2 = Vector2.ZERO


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("enemy")
	call_deferred("player_setup")


func _physics_process(delta: float) -> void:
	if player == null || !is_instance_valid(player):
		velocity = Vector2.ZERO
		return
	
	var can_see_player = check_line_of_sight()
	
	match current_state:
		State.PATROL:
			if can_see_player:
				current_state = State.CHASE
				last_known_player_pos = player.global_position
			else:
				patrol_behavior(delta)
		State.CHASE:
			if can_see_player:
				last_known_player_pos = player.global_position
			chase_behavior()
	
	move_and_slide()
	handle_wall_collision()
	update_animation()
	update_facing()
	check_player_collision()


func player_setup() -> void:
	await get_tree().physics_frame
	player = get_tree().get_first_node_in_group("player")
	pick_random_patrol_direction()


func check_line_of_sight() -> bool:
	if player == null || !is_instance_valid(player):
		return false
		
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > vision_range:
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position,
		1  # Collision mask - walls only (physics_layer_0)
	)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	return result.is_empty()  # No obstacle = can see player


func patrol_behavior(delta: float) -> void:
	patrol_timer += delta
	if patrol_timer >= direction_change_time:
		patrol_timer = 0.0
		pick_random_patrol_direction()
	
	velocity = patrol_direction * patrol_speed


func chase_behavior() -> void:
	var target_pos = last_known_player_pos
	var distance_to_target = global_position.distance_to(target_pos)
	
	if distance_to_target < 5.0:
		current_state = State.PATROL
		pick_random_patrol_direction()
		return
	
	velocity = global_position.direction_to(target_pos) * chase_speed


func pick_random_patrol_direction() -> void:
	var angle = randf() * TAU  # Random angle 0-2π
	patrol_direction = Vector2.from_angle(angle)


func handle_wall_collision() -> void:
	if current_state == State.PATROL and get_slide_collision_count() > 0:
		pick_random_patrol_direction()
		patrol_timer = 0.0


func update_animation() -> void:
	if velocity.length() > 1.0:
		sprite.play("walk")
	else:
		sprite.play("idle")


func update_facing() -> void:
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0


func check_player_collision() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player") and collider.has_method("die"):
			collider.die()


func die() -> void:
	queue_free()
