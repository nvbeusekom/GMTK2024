extends CharacterBody2D

@export var SPEED = 240
var score = 0
var threshold1 = 2
var threshold2 = 5
var threshold3 = 10
var threshold4 = 15
var paused = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$MusicSafe.play()

func pause():
	paused = true
func unpause():
	paused = false
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return
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
		if !$AudioStreamPlayer2D.playing:
			$AudioStreamPlayer2D.play()
		velocity = velocity.normalized() * SPEED
		look_at(global_position + velocity)
		rotation = rotation + deg_to_rad(90)
		if score >= threshold4:
			$AnimatedSprite2D.animation = "Walk4"
		elif score >= threshold3:
			$AnimatedSprite2D.animation = "Walk3"
		elif score >= threshold2:
			$AnimatedSprite2D.animation = "Walk2"
		elif score >= threshold1:
			$AnimatedSprite2D.animation = "Walk1"
		else:
			$AnimatedSprite2D.animation = "Walk0"
	else:
		$AudioStreamPlayer2D.stop()
		if score >= threshold4:
			$AnimatedSprite2D.animation = "Idle4"
		elif score >= threshold3:
			$AnimatedSprite2D.animation = "Idle3"
		elif score >= threshold2:
			$AnimatedSprite2D.animation = "Idle2"
		elif score >= threshold1:
			$AnimatedSprite2D.animation = "Idle1"
		else:
			$AnimatedSprite2D.animation = "Idle0"
	
	get_tree().get_nodes_in_group("camera")[0].position = global_position
	
	move_and_slide()
	
func _on_food_touch(amount):
	score += amount
	if score >= threshold4:
		SPEED = 90
		$CollisionShape2D.scale = Vector2(9,9)
		$AudioStreamPlayer2D.pitch_scale = 0.5
		get_tree().get_nodes_in_group("camera")[0].set_zoom(Vector2(1.6,1.6))
		get_tree().root.get_child(0).big_boy_time();
	elif score >= threshold3:
		SPEED = 110
		$CollisionShape2D.scale = Vector2(4.5,4.5)
		$AudioStreamPlayer2D.pitch_scale = 0.8
		get_tree().get_nodes_in_group("camera")[0].set_zoom(Vector2(1.8,1.8))
	elif score >= threshold2:
		SPEED = 130
		$CollisionShape2D.scale = Vector2(3,3)
		$AudioStreamPlayer2D.pitch_scale = 1
		get_tree().get_nodes_in_group("camera")[0].set_zoom(Vector2(2,2))
	elif score >= threshold1:
		SPEED = 160
		$CollisionShape2D.scale = Vector2(1.7,1.7)
		$AudioStreamPlayer2D.pitch_scale = 1.5
		get_tree().get_nodes_in_group("camera")[0].set_zoom(Vector2(2.2,2.2))
	
# It's joever
func _on_guard_touch():
	get_tree().root.get_child(0).game_over();
