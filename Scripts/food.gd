extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.has_method("_on_food_touch"):
		for seeker in get_tree().get_nodes_in_group("seeker"):
			seeker._on_sound_heard(global_position)
		body._on_food_touch(1)
		body.get_node("Eating").play()
		$Sprite2D.queue_free()
		$Area2D.queue_free()
	
