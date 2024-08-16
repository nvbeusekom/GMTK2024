extends CharacterBody2D

@export var SPEED = 240
var score = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		#if not lockDirection:
		#	lookingLeft = false
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		#if not lockDirection:
		#	lookingLeft = true
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_just_pressed("emit_sound"):
		for seeker in get_tree().get_nodes_in_group("seeker"):
			seeker._on_sound_heard(global_position)
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
	
	move_and_slide()
	
func _on_food_touch(amount):
	print("Food touched")
	score += amount
	scale.x += .5
	scale.y += .5
	get_tree().get_nodes_in_group("camera")[0].set_zoom(get_tree().get_nodes_in_group("camera")[0].get_zoom() * Vector2(.9,.9))
	
