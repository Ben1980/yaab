extends CharacterBody2D

@export var speed: float = 30
@export var cooldown_time: float = 0.2
@export var controller_deadzone: float = 0.1
@export var velocity_threshold: float = 0.1
@export var sprite_speed_scale: float = 2.0
@export var run_speed_factor: float = 2.1

var aim_direction: Vector2 = Vector2.RIGHT
var is_dead: bool = false
var can_fire: bool = true
var controller_available: bool = false
var using_controller: bool = false
var observed_stick_max: float = 0.7
var player_speed_factor: float = 1.0

const LASER_SCENE: PackedScene = preload("res://weapons/laser.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_cooldown: Timer = $FireCooldown

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
		
		if Input.is_action_pressed("shoot"):
			fire()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	get_input()
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

func die() -> void:
	if is_dead:
		return
	is_dead = true
	game_over.emit()

func fire() -> void:
	if not can_fire:
		return
	
	can_fire = false
	
	var laser = LASER_SCENE.instantiate()
	laser.direction = aim_direction
	laser.global_position = global_position
	laser.rotation = rotation - PI
	get_parent().add_child(laser)
	fire_cooldown.start(cooldown_time)

func _on_fire_cooldown_timeout() -> void:
	can_fire = true

func _on_joy_connection_changed(_device_id: int, _connected: bool) -> void:
	controller_available = Input.get_connected_joypads().size() > 0
	if not controller_available:
		using_controller = false
