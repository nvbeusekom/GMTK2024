extends Node2D

var init = true;
var help_screen = load("res://Scenes/help_screen.tscn")
var help_node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/ColorRect.size = DisplayServer.window_get_size();
	$CanvasLayer/MusicSlider.value = get_tree().root.get_child(0).music_volume;
	$CanvasLayer/SoundSlider.value = get_tree().root.get_child(0).sound_volume;
	init = false;
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	pass

func _on_continue_pressed() -> void:
	get_tree().root.get_child(0).unpause();



func _on_restart_pressed() -> void:
	#var player = get_tree().get_nodes_in_group("player")[0]
	#player.global_position = Vector2(45,45)
	get_tree().root.get_child(0).clear_game();
	
	#if player.get_node("MusicChase").playing:
	#	player.get_node("MusicChase").stop()
	#if !player.get_node("MusicSafe").playing:
	#	player.get_node("MusicSafe").play()
	get_tree().get_nodes_in_group("main")[0]._game_start()
	#get_tree().get_nodes_in_group("player")[0].

func _on_quit_pressed() -> void:
	get_tree().root.get_child(0).clear_game();
	get_tree().root.get_child(0).open_main_menu();


func _on_music_slider_value_changed(value: float) -> void:
	if(!init):
		get_tree().root.get_child(0).music_volume = value;
		for node in get_tree().get_nodes_in_group("music"):
			node.volume_db = node.get_meta("basic_db") -40 + 0.4 * value;
		


func _on_sound_slider_value_changed(value: float) -> void:
	if(!init):
		get_tree().root.get_child(0).sound_volume = value;
		for node in get_tree().get_nodes_in_group("sound"):
			node.volume_db = node.get_meta("basic_db") - 40 + 0.4 * value;
		$CanvasLayer/AudioStreamPlayer2D.play();


func _on_texture_button_pressed() -> void:
	help_node = help_screen.instantiate();
	add_child(help_node);
