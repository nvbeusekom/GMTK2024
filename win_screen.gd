extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_win_0_go_timeout() -> void:
	$CanvasLayer/win0.set("z_index",0)

func _on_win_1_go_timeout() -> void:
	$CanvasLayer/win1.set("z_index",0)

func _on_win_2_go_timeout() -> void:
	$CanvasLayer/win2.set("z_index",0)

func _on_winfullgo_timeout() -> void:
	$CanvasLayer/winfull.set("z_index",1)

func _on_flashlights_timeout() -> void:
	var color = $CanvasLayer/Label.get("theme_override_colors/font_color")
	$CanvasLayer/Label.set("theme_override_colors/font_color", Color(color.b,color.r,color.g,color.a))
