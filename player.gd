extends CharacterBody2D


@export var SPEED = 1


func get_input():
	look_at(get_global_mouse_position())
	rotation += PI/2
	var forward = transform.y.normalized() * -Input.get_axis("move_down", "move_up")
	var strafe = transform.x.normalized() * Input.get_axis("move_left", "move_right")
	velocity = (forward + strafe).normalized() * SPEED


func _physics_process(delta):
	get_input()
	move_and_slide()
	
