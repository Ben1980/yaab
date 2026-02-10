extends CharacterBody2D

@export var life: int = 100
@export var patrol_speed: float = 30.0
@export var chase_speed: float = 100.0
@export var vision_range: float = 300.0
@export var direction_change_time: float = 2.0 
@export var velocity_threshold: float = 1.0
@export var rotation_speed: float = 10.0
@export var sprite_speed_scale: float = 2.0
@export var recoil_distance: float = 3.0
@export var recoil_duration: float = 0.02
@export var min_ping_interval: float = 0.1
@export var max_ping_interval: float = 4.0
@export var min_ping_pitch: float = 0.5
@export var max_ping_pitch: float = 1.5

enum State { PATROL, CHASE }
var current_state: State = State.PATROL
var player: CharacterBody2D = null
var patrol_direction: Vector2 = Vector2.ZERO
var patrol_timer: float = 0.0
var last_known_player_pos: Vector2 = Vector2.ZERO
var query: PhysicsRayQueryParameters2D = null
var recoil_tween: Tween
var is_pinging: bool = false
var is_closest_to_player: bool = false 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ping: AudioStreamPlayer2D = $Ping
@onready var ping_timer: Timer = $PingTimer
@onready var growl: AudioStreamPlayer2D = $Growl
@onready var growl_timer: Timer = $GrowlTimer

signal enemy_died

func _ready() -> void:
	query = PhysicsRayQueryParameters2D.new()
	growl_timer.wait_time = randf_range(5.0, 30.0)
	
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
				sprite.speed_scale = sprite_speed_scale
			else:
				patrol_behavior(delta)
				sprite.speed_scale = 1.0 
		State.CHASE:
			if can_see_player:
				last_known_player_pos = player.global_position
			chase_behavior()
	
	move_and_slide()
	handle_wall_collision()
	update_animation()
	update_facing(delta)
	check_player_collision()
	pinging()

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
	if query:
		query.from = global_position
		query.to = player.global_position
		query.collision_mask = 1
		query.exclude = [self]
	else:
		return false
	
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
	if velocity.length() > velocity_threshold:
		sprite.play("walk")
	else:
		sprite.play("idle")

func update_facing(delta: float) -> void:
	const offset: float = PI/2
	
	if velocity.length() > velocity_threshold:
		var target_angle = velocity.angle() - offset
		self.rotation = lerp_angle(self.rotation, target_angle, delta * rotation_speed)

func check_player_collision() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player") and collider.has_method("hit"):
			collider.hit()

func hit() -> void:
	life -= 10
	apply_recoil()
	if life <= 0:
		growl_timer.stop()
		enemy_died.emit()
		queue_free()

func apply_recoil() -> void:
	if recoil_tween and recoil_tween.is_valid():
		recoil_tween.kill()
	
	recoil_tween = create_tween()
	recoil_tween.tween_property(sprite, "position", Vector2(0, recoil_distance), recoil_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	recoil_tween.tween_property(sprite, "position", Vector2.ZERO, recoil_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func pinging() -> void:
	var distance_to_player = global_position.distance_to(player.global_position)
	var should_ping = distance_to_player <= ping.max_distance and is_closest_to_player
	
	if should_ping and not is_pinging:
		ping_timer.start()
		is_pinging = true
	elif not should_ping and is_pinging:
		ping_timer.stop()
		is_pinging = false
	
	if is_pinging:
		var ratio = clampf(distance_to_player / ping.max_distance, 0.0, 1.0)
		ping_timer.wait_time = lerpf(min_ping_interval, max_ping_interval, ratio)
		ping.pitch_scale = lerpf(max_ping_pitch, min_ping_pitch, ratio)

func _on_ping_timer_timeout() -> void:
	ping.play()

func _on_growl_timer_timeout() -> void:
	growl.play()
	growl_timer.wait_time = randf_range(5.0, 30.0)
