extends Camera2D

var zoom_delta = 0.01;
var zoom_goal = Vector2(2.2,2.2);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_zoom(Vector2(1.6,1.6))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var z = get_zoom();
	if(z < zoom_goal):
		set_zoom(Vector2(z.x+zoom_delta,z.y+zoom_delta));
	elif(z > zoom_goal):
		set_zoom(Vector2(z.x-zoom_delta,z.y-zoom_delta));

func set_zoom_speed(delta):
	zoom_delta = delta

func smooth_zoom(z):
	zoom_goal = z;
