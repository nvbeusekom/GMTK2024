extends Node2D
var tippedOver = false
var counter = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and !tippedOver:
		if body.score >= body.threshold2:
			look_at(body.global_position)
			rotation = rotation - deg_to_rad(90)
			$AnimatedSprite2D.play()
			tippedOver = true
			

func _on_animated_sprite_2d_frame_changed() -> void:
	counter += 1
	if counter == 3:
		for seeker in get_tree().get_nodes_in_group("seeker"):
				seeker._on_sound_heard(global_position)
		$AudioStreamPlayer2D.play()
