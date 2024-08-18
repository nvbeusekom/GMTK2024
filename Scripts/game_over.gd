extends Node2D

var blackscreen_delta = 0.035;
var text_delta = 0.008
var label_theme = null

var color = Color(130,0,0,0);

var text_shown = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_theme = $CanvasLayer/CenterContainer/Label.theme
	var center = $CanvasLayer/CenterContainer
	$CanvasLayer/ColorRect.size = DisplayServer.window_get_size();
	center.position = Vector2(DisplayServer.window_get_size().x/2,DisplayServer.window_get_size().y/2);
	$CanvasLayer/CenterContainer/Label.add_theme_color_override("font_color",color);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if($CanvasLayer/ColorRect.color.a < 1):
		$CanvasLayer/ColorRect.color.a += blackscreen_delta;
	elif(color.a < 1 && !text_shown):
		color.a += text_delta;
		if(color.a >= 1):
			text_shown = true;
		$CanvasLayer/CenterContainer/Label
		$CanvasLayer/CenterContainer/Label.remove_theme_color_override("font_color");
		$CanvasLayer/CenterContainer/Label.add_theme_color_override("font_color",color);
	elif(color.a > 0):
		color.a -= text_delta;
		$CanvasLayer/CenterContainer/Label.remove_theme_color_override("font_color");
		$CanvasLayer/CenterContainer/Label.add_theme_color_override("font_color",color);
	else:
		end_death_screen();
		
func end_death_screen():
	get_tree().root.get_child(0).clear_game();
	get_tree().root.get_child(0).open_main_menu();
	self.queue_free();
	
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		end_death_screen();
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_ESCAPE || event.keycode == KEY_SPACE):
			end_death_screen();
