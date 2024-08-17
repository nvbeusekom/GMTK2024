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
	get_tree().reload_current_scene();


func _on_quit_pressed() -> void:
	get_tree().quit();
