extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var vision_renderer: Polygon2D
@export var is_rotating = false
@export var rotation_speed = 1
@export var rotation_angle = 90
@export var alert_color: Color

@onready var rot_start = rotation
@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
var goal
var targetPos = Vector2(0,0)
var playerSeen = false
var soundHeard = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var movement_speed = 40.0
var movement_delta
var angle_to_player


func _physics_process(delta):
	if playerSeen:
		soundHeard = false
		targetPos = get_tree().get_nodes_in_group("player")[0].global_position
		
	else:
		rotation = rotation + deg_to_rad(2)#rot_start + sin(Time.get_ticks_msec()/1000. * rotation_speed) * deg_to_rad(rotation_angle/2.)
			
	if soundHeard and (global_position - targetPos).length() < 2: 
		soundHeard = false
	
	if playerSeen or soundHeard:
		
		
		$NavigationAgent2D.set_target_position(targetPos)
		movement_delta = movement_speed * delta
		var next_path_position: Vector2 = $NavigationAgent2D.get_next_path_position()
		var current_agent_position: Vector2 = global_position
		var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * movement_delta
		look_at(next_path_position)
		rotation = rotation-deg_to_rad(90)
		if $NavigationAgent2D.avoidance_enabled:
			$NavigationAgent2D.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	# print("%s is seeing %s" % [self, body])
	vision_renderer.color = alert_color
	playerSeen = true
	#start pathfinding
	
func _on_vision_cone_area_body_exited(body: Node2D) -> void:
	# print("%s stopped seeing %s" % [self, body])
	vision_renderer.color = original_color
	playerSeen = false
	#start lose interest timer
	
func _on_sound_heard(soundOrigin: Vector2) -> void:
	if !playerSeen:
		soundHeard = true
		targetPos = soundOrigin
	
