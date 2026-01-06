extends CharacterBody2D


@export var SPEED = 1


var is_dead: bool = false
var laser_scene: PackedScene

func get_input():
	look_at(get_global_mouse_position())
	rotation += PI/2
	var forward = transform.y.normalized() * -Input.get_axis("move_down", "move_up")
	var strafe = transform.x.normalized() * Input.get_axis("move_left", "move_right")
	velocity = (forward + strafe).normalized() * SPEED
	
	if (Input.is_action_pressed("shoot")):
		fire()


func _physics_process(delta):
	get_input()
	move_and_slide()


func _ready():
	laser_scene = preload("res://laser.tscn")
	add_to_group("player")


func die() -> void:
	if is_dead:
		return
	is_dead = true
	get_tree().reload_current_scene()


func fire() -> void:
	var laser = laser_scene.instantiate()
	laser.global_position = global_position
	laser.rotation = rotation
	get_parent().add_child(laser)
