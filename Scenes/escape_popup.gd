extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_timer_timeout() -> void:
	var color = $CanvasLayer/ColorRect.get_color()
	$CanvasLayer/ColorRect.set_color(Color(color.b,color.r,color.g,color.a*0.9))
	#color = $CanvasLayer/Label.label_settings.font_color
	color = $CanvasLayer/Label.get("theme_override_colors/font_color")
	$CanvasLayer/Label.set("theme_override_colors/font_color", Color(color.b,color.r,color.g,color.a*0.9))
	#$CanvasLayer/Label.remove_theme_color_override(color)
	#$CanvasLayer/Label.add_theme_color_overrride(Color(color.b,color.r,color.g,color.a*0.9))
	if color.a <= .1:
		queue_free()
