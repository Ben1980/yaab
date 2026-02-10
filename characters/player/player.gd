extends CharacterBody2D

@export var speed: float = 90
@export var cooldown_time: float = 0.1
@export var controller_deadzone: float = 0.1
@export var velocity_threshold: float = 0.1
@export var sprite_speed_scale: float = 2.0
@export var run_speed_factor: float = 2.1
@export var spread_threshold: int = 200
@export var spread_per_shot: int = 1
@export var max_spread: int = 5
@export var recoil_distance: float = 3.0
@export var recoil_duration: float = 0.02
@export var min_heartbeat_interval: float = 0.05
@export var max_heartbeat_interval: float = 1.0
@export var max_enemy_distance: float = 400.0

var aim_direction: Vector2 = Vector2.RIGHT
var is_dead: bool = false
var can_fire: bool = true
var controller_available: bool = false
var using_controller: bool = false
var observed_stick_max: float = 0.7
var player_speed_factor: float = 1.0
var last_shot_time: int = 0
var consecutive_shots: int = 0
var recoil_tween: Tween

const BULLET_SCENE: PackedScene = preload("res://weapons/bullet.tscn")
const MUZZLE_FLASH_SCENE: PackedScene = preload("res://weapons/muzzle_flash.tscn")
const SHELL_SCENE: PackedScene = preload("res://weapons/shell.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_cooldown: Timer = $FireCooldown
@onready var muzzle_point: Marker2D = $AnimatedSprite2D/MuzzlePoint
@onready var heartbeat: AudioStreamPlayer = $Heartbeat
@onready var heartbeat_timer: Timer = $HeatbeatTimer
@onready var flatline: AudioStreamPlayer = $Flatline
@onready var gunshot: AudioStreamPlayer = $Gunshot

signal game_over

func get_input() -> void:
	if not is_dead:
		if controller_available:
			var stick_aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
			if stick_aim.length() > controller_deadzone:
				using_controller = true
				aim_direction = stick_aim.normalized()
				rotation = aim_direction.angle() + PI/2
		
		if not using_controller:
			look_at(get_global_mouse_position())
			rotation += PI/2
			aim_direction = (get_global_mouse_position() - global_position).normalized()
		
		if using_controller:
			var move_input = Vector2(
				Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
				Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
			)
			var raw_length = move_input.length()
			
			if raw_length > observed_stick_max:
				observed_stick_max = raw_length
			
			var speed_factor = clamp(raw_length / observed_stick_max, 0.0, 1.0) * player_speed_factor
			
			if raw_length > controller_deadzone:
				velocity = aim_direction * speed_factor * speed
			else:
				velocity = Vector2.ZERO
		else:
			var forward_input = Input.get_axis("move_down", "move_up")
			velocity = -transform.y.normalized() * forward_input * speed * player_speed_factor

func _input(event: InputEvent) -> void:
	if not is_dead:
		if event is InputEventMouseMotion or event is InputEventMouseButton:
			if not controller_available or Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down").length() < controller_deadzone:
				using_controller = false
		
		if event.is_action_pressed("player_run"):
			player_speed_factor = run_speed_factor
			sprite.speed_scale = sprite_speed_scale
		
		if event.is_action_released("player_run"):
			player_speed_factor = 1.0
			sprite.speed_scale = 1.0

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	get_input()
	
	if Input.is_action_pressed("shoot"):
		fire()
	
	var closest_distance = INF
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance_to_player = enemy.position.distance_to(global_position)
			if distance_to_player < closest_distance:
				closest_distance = distance_to_player
				var ratio = clampf(distance_to_player / max_enemy_distance, 0.0, 1.0)
				heartbeat_timer.wait_time = lerpf(min_heartbeat_interval, max_heartbeat_interval, ratio)
			
	update_animation()
	move_and_slide()

func _ready() -> void:
	add_to_group("player")
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	controller_available = Input.get_connected_joypads().size() > 0

func update_animation() -> void:
	if velocity.length() > velocity_threshold:
		sprite.play("walk")
	else:
		sprite.play("idle")

func hit() -> void:
	if is_dead:
		return
	is_dead = true
	game_over.emit()
	
	flatline.play()
	var flatline_tween = get_tree().create_tween()
	flatline_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	flatline_tween.tween_property(flatline, "volume_db", -80, 8).set_trans(Tween.TRANS_LINEAR)
	flatline_tween.tween_callback(flatline.stop)

func fire() -> void:
	if not can_fire:
		return
	
	can_fire = false
	
	add_muzzle_flash()
	add_bullet()
	add_shell()
	apply_recoil()
	gunshot.play()
	
	fire_cooldown.start(cooldown_time)

func _on_fire_cooldown_timeout() -> void:
	can_fire = true

func _on_joy_connection_changed(_device_id: int, _connected: bool) -> void:
	controller_available = Input.get_connected_joypads().size() > 0
	if not controller_available:
		using_controller = false

func add_muzzle_flash() -> void:
	var muzzle_flash = MUZZLE_FLASH_SCENE.instantiate()
	var offset_distance = muzzle_flash.get_length() / 2.0
	muzzle_flash.global_position = muzzle_point.global_position + (aim_direction * offset_distance)
	muzzle_flash.rotation = self.rotation + PI
	get_parent().add_child(muzzle_flash)

func add_bullet() -> void:
	var current_time = Time.get_ticks_msec()
	var time_since_last = current_time - last_shot_time
	
	if time_since_last < spread_threshold:
		consecutive_shots += 1
	else:
		consecutive_shots = 0
	
	var spread_angle = min(consecutive_shots * spread_per_shot, max_spread)
	var random_offset = randi_range(-spread_angle, spread_angle)
	
	var bullet = BULLET_SCENE.instantiate()
	bullet.direction = aim_direction.rotated(deg_to_rad(random_offset))
	last_shot_time = current_time
	bullet.global_position = muzzle_point.global_position
	bullet.rotation = rotation - PI
	get_parent().add_child(bullet)

func add_shell() -> void:
	var shell = SHELL_SCENE.instantiate()
	shell.direction = aim_direction.rotated(PI/2)
	shell.rotation = PI
	
	var ejection_offset = 10.0
	shell.global_position = muzzle_point.global_position - (aim_direction * ejection_offset)
	get_parent().add_child(shell)

func apply_recoil() -> void:
	if recoil_tween and recoil_tween.is_valid():
		recoil_tween.kill()
	
	recoil_tween = create_tween()
	recoil_tween.tween_property(sprite, "position", Vector2(0, recoil_distance), recoil_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	recoil_tween.tween_property(sprite, "position", Vector2.ZERO, recoil_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_heatbeat_timer_timeout() -> void:
	heartbeat.play()
