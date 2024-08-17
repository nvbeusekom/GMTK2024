extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@export var noise : NoiseTexture2D;
@export var width = 10;
@export var height = 10;


func generate():
	var lowest_value = 0;
	var lowest_x = 0;
	var lowest_y = 0;
	
	# Place first tile as empty 
	
	for x in range(width):
		for y in range(height):
			if(lowest_value == 0):
				# Place empty
				pass
			else:
				pass
				# Place any of remaining
