extends CharacterBody2D


@export var SPEED: float = 30
@export var COOLDOWN_TIME: float = 0.2

var is_dead: bool = false
var can_fire: bool = true

const LASER_SCENE: PackedScene = preload("res://laser.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_cooldown: Timer = $FireCooldown


func get_input() -> void:
	look_at(get_global_mouse_position())
	rotation += PI/2
	var forward = transform.y.normalized() * -Input.get_axis("move_down", "move_up")
	var strafe = transform.x.normalized() * Input.get_axis("move_left", "move_right")
	velocity = (forward + strafe).normalized() * SPEED
	

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("shoot"):
		fire()


func _physics_process(delta: float) -> void:
	get_input()
	update_animation()
	move_and_slide()


func _ready() -> void:
	add_to_group("player")


func update_animation() -> void:
	if velocity.length() > 1.0:
		sprite.play("walk")
	else:
		sprite.play("idle")


func die() -> void:
	if is_dead:
		return
	is_dead = true
	get_tree().reload_current_scene()


func fire() -> void:
	if !can_fire:
		return
	
	can_fire = false
	
	var laser = LASER_SCENE.instantiate()
	laser.direction = (get_global_mouse_position() - global_position).normalized()
	laser.global_position = global_position
	laser.rotation = rotation - PI
	get_parent().add_child(laser)
	fire_cooldown.start(COOLDOWN_TIME)


func _on_fire_cooldown_timeout() -> void:
	can_fire = true
