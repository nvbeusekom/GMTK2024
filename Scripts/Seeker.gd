extends CharacterBody2D

@export var vision_renderer: Polygon2D
@export var is_rotating = false
@export var rotation_speed = 1
@export var rotation_angle = 90
@export var alert_color: Color
@export var sound_color: Color

@onready var rot_start = rotation
@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE

var rng = RandomNumberGenerator.new()
var goal
var targetPos = Vector2(0,0)
var lastKnownPos = Vector2(0,0)
var playerSeen = false
var stillFollowing = false
var soundHeard = false
var paused = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var movement_speed = 80.0
var movement_delta
var angle_to_player

func pause():
	paused = true
func unpause():
	paused = false
	
func _physics_process(delta):
	if paused:
		return
	if playerSeen:
		soundHeard = false
		targetPos = get_tree().get_nodes_in_group("player")[0].global_position
		if stillFollowing:
			targetPos = lastKnownPos
			if (global_position - targetPos).length() < 10 and $seenWait.time_left == 0:
				$seenWait.start()
				
	if soundHeard and (global_position - targetPos).length() < 10 and $soundWait.time_left == 0: 
		$soundWait.start()     
	
	if get_tree().get_nodes_in_group("player")[0].score >= get_tree().get_nodes_in_group("player")[0].threshold4 and (global_position - get_tree().get_nodes_in_group("player")[0].global_position).length() < 450:
		targetPos = global_position + (global_position - get_tree().get_nodes_in_group("player")[0].global_position).normalized()
	$NavigationAgent2D.set_target_position(targetPos)
	if !$NavigationAgent2D.is_target_reachable() and $unreachableWait.time_left == 0:
		$unreachableWait.start()
	movement_delta = movement_speed * delta
	var next_path_position: Vector2 = $NavigationAgent2D.get_next_path_position()
	var current_agent_position: Vector2 = global_position
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * movement_delta
	look_at(next_path_position)
	rotation = rotation-deg_to_rad(90)
	if (global_position - targetPos).length() > 1:
		if $NavigationAgent2D.avoidance_enabled:
			$NavigationAgent2D.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		vision_renderer.color = alert_color
		playerSeen = true
		if body.get_node("MusicSafe").playing:
			body.get_node("MusicSafe").stop()
		if !body.get_node("MusicChase").playing:
			body.get_node("MusicChase").play()
		movement_speed = 150
		$seenWait.stop()
	#start pathfinding
	
func _on_vision_cone_area_body_exited(body: Node2D) -> void:
	lastKnownPos = get_tree().get_nodes_in_group("player")[0].global_position
	stillFollowing = true
	$seenWait.start()
	#start lose interest timer
	
func _on_sound_heard(soundOrigin: Vector2) -> void:
	if !playerSeen:
		$soundWait.stop()
		vision_renderer.color = sound_color
		soundHeard = true
		movement_speed = 110
		targetPos = soundOrigin
		$NavigationAgent2D.set_target_position(targetPos)
		if !$NavigationAgent2D.is_target_reachable():
			randomPath()

func _on_autopath_idle_timeout() -> void:
	randomPath()

func randomPath():
	if !playerSeen and !soundHeard:
		var eligibleList = []
		var tpList = []
		for cell in get_tree().get_nodes_in_group("navigation")[0].get_used_cells_by_id(0,Vector2i(3,2)):
			if (get_tree().get_nodes_in_group("navigation")[0].map_to_local(cell) - get_tree().get_nodes_in_group("player")[0].global_position).length() > 500:
				tpList.append(cell)
			eligibleList.append(cell)
		if (get_tree().get_nodes_in_group("player")[0].global_position - global_position).length() > 500 and (get_tree().get_nodes_in_group("player")[0].global_position - global_position).length() < 800: # and rng.randf_range(0,10) > 5
			global_position = get_tree().get_nodes_in_group("navigation")[0].map_to_local(tpList.pick_random())
			print("teleport")
		targetPos = get_tree().get_nodes_in_group("navigation")[0].map_to_local(eligibleList.pick_random())
			
func _on_seen_wait_timeout() -> void:
	vision_renderer.color = original_color
	playerSeen = false
	stillFollowing = false
	movement_speed = 80
	randomPath()
	for seeker in get_tree().get_nodes_in_group("seeker"):
		if seeker.playerSeen:
			return
	if get_tree().get_nodes_in_group("player")[0].get_node("MusicChase").playing:
		get_tree().get_nodes_in_group("player")[0].get_node("MusicChase").stop()
	if !get_tree().get_nodes_in_group("player")[0].get_node("MusicSafe").playing:
		get_tree().get_nodes_in_group("player")[0].get_node("MusicSafe").play()
		

func _on_sound_wait_timeout() -> void:
	soundHeard = false
	movement_speed = 80
	randomPath()


func _on_unreachable_wait_timeout() -> void:
	soundHeard = false
	playerSeen = false
	vision_renderer.color = original_color
	randomPath()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().root.get_child(0).game_over();
