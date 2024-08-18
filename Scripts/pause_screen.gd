extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/ColorRect.size = DisplayServer.window_get_size();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_continue_pressed() -> void:
	get_tree().root.get_child(0).unpause();

func _on_restart_pressed() -> void:
	#var player = get_tree().get_nodes_in_group("player")[0]
	#player.global_position = Vector2(45,45)
	
	get_tree().get_nodes_in_group("camera")[0].global_position = Vector2(45,45)
	#player.score = 0
	for node in get_tree().get_nodes_in_group("delete"):
		node.queue_free()
	#if player.get_node("MusicChase").playing:
	#	player.get_node("MusicChase").stop()
	#if !player.get_node("MusicSafe").playing:
	#	player.get_node("MusicSafe").play()
	get_tree().get_nodes_in_group("main")[0]._game_start()
	#get_tree().get_nodes_in_group("player")[0].

func _on_quit_pressed() -> void:
	get_tree().quit();
