extends Node2D


@export var noise : NoiseTexture2D;
@export var width = 10;
@export var height = 10;

@onready var tile_map = $NavigationRegion2D/TileMapLayer
@onready var navigation_region = $NavigationRegion2D

var numberOfSeekers = 2
var numberOfFood = 12
var numberOfCans = 20
var food = load("res://Scenes/food.tscn")
var seeker = load("res://Scenes/seeker.tscn")
var can = load("res://Scenes/can.tscn")
var pause_node = null
var pauseScreen = load("res://Scenes/pauseScreen.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate();
	bake_nav();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pause(node):
	for child in node.get_children():
		if child.has_method("pause"):
			child.pause()
		pause(child) 
		
func unpause(node):
	for child in node.get_children():
		if child.has_method("unpause"):
			child.unpause()
		unpause(child) 

func _input(event):
	if Input.is_action_pressed("pause"):
		if pause_node == null:
			pause(self)
			pause_node = pauseScreen.instantiate()
			add_child(pause_node)
		else:
			unpause(self)
			pause_node.queue_free()


var source_id = 0;
var horizontal_atlas = Vector2i(0,0);
var vertical_atlas = Vector2i(1,0);
var left_down_atlas = Vector2i(2,0);
var left_up_atlas = Vector2i(3,0);
var right_up_atlas = Vector2i(4,0);
var right_down_atlas = Vector2i(5,0);
var t_down_atlas = Vector2i(6,0);
var t_left_atlas = Vector2i(7,0);
var t_up_atlas = Vector2i(0,1);
var t_right_atlas = Vector2i(1,1);
var cross_atlas = Vector2i(2,1);
var left_atlas = Vector2i(3,1);
var up_atlas = Vector2i(4,1);
var right_atlas = Vector2i(5,1);
var down_atlas = Vector2i(6,1);
var horizontal_gap1_atlas = Vector2i(7,1);
var vertical_gap1_atlas = Vector2i(0,2);
var horizontal_gap2_atlas = Vector2i(1,2);
var vertical_gap2_atlas = Vector2i(2,2);
var empty_atlas = Vector2i(3,2);



var connections = {
	horizontal_atlas: ["left","right"],
	vertical_atlas: ["up","down"],
	left_down_atlas: ["left","down"],
	left_up_atlas: ["left","up"],
	right_up_atlas: ["right","up"],
	right_down_atlas: ["right","down"],
	t_down_atlas: ["left","right","down"],
	t_left_atlas: ["left","up","down"],
	t_up_atlas: ["left","right","up"],
	t_right_atlas: ["right","up","down"],
	cross_atlas: ["left","right","up","down"],
	left_atlas: ["left"],
	up_atlas: ["up"],
	right_atlas: ["right"],
	down_atlas: ["down"],
	horizontal_gap1_atlas: ["left","right"],
	vertical_gap1_atlas: ["up","down"],
	horizontal_gap2_atlas: ["left","right"],
	vertical_gap2_atlas: ["up","down"],
	empty_atlas: []
}

func get_impossible_neighbours(contains,direction):
	var neighbours = []
	for key in connections.keys():
		if(contains != connections[key].has(direction)):
			neighbours.append(key);
	return neighbours;

func bake_nav():
	var nav_polygon = NavigationPolygon.new();
	var bounding_outline = PackedVector2Array([Vector2i(0, 0), Vector2i(0, height*64), Vector2i(width*64, height*64), Vector2i(height*64, 0)]);
	nav_polygon.add_outline(bounding_outline);
	navigation_region.navigation_polygon = nav_polygon;
	navigation_region.bake_navigation_polygon(false);
	
func generate():
	
	# Initially, assume that all neighbours are possible everywhere. These arrays are reduced throughout generation
	var possibilities = {};
	for x in range(width):
		for y in range(height):
			possibilities[Vector2i(x,y)] = [horizontal_atlas,
											vertical_atlas,
											left_down_atlas,
											left_up_atlas,
											right_up_atlas,
											right_down_atlas,
											t_down_atlas,
											t_left_atlas,
											t_up_atlas,
											t_right_atlas,
											cross_atlas,
											left_atlas,
											up_atlas,
											right_atlas,
											down_atlas,
											horizontal_gap1_atlas,
											vertical_gap1_atlas,
											horizontal_gap2_atlas,
											vertical_gap2_atlas,
											empty_atlas];
	
	# Make array of cells that are on the edge for efficiency
	var cells_on_edge = [Vector2i(0,0)];
	var cells_placed = [];
	
	# Place first tile as empty 
	var init = true;
	
	while(cells_on_edge.size() > 0):
		var placing = cells_on_edge[0];
		for i in range(1,cells_on_edge.size()):
			if(possibilities[cells_on_edge[i]].size() < possibilities[placing].size()):
				placing = cells_on_edge[i];
		
		# TODO Better RNG
		var tyle_type = possibilities[placing].pick_random();
		if(possibilities[placing].has(empty_atlas) && randf() < 0.7):
			tyle_type = empty_atlas;
		
		
		if(init):
			# Place empty
			tyle_type = empty_atlas;
			init = false;
			# Place any of remaining
	
		tile_map.set_cell(placing,source_id,tyle_type);
		# Update surrounding neighbours and cells on edge
		cells_placed.append(placing);
		cells_on_edge.erase(placing);
		# Left
		var left = Vector2i(placing.x-1,placing.y);
		if(placing.x > 0 && !cells_placed.has(left)):
			if(! cells_on_edge.has(left)):
				cells_on_edge.append(left);
			for impossible in get_impossible_neighbours(connections[tyle_type].has("left"),"right"):
				possibilities[left].erase(impossible);
		
		# Right
		var right = Vector2i(placing.x+1,placing.y);
		if(placing.x < width-1 && !cells_placed.has(right)):
			if(! cells_on_edge.has(right)):
				cells_on_edge.append(right);
			for impossible in get_impossible_neighbours(connections[tyle_type].has("right"),"left"):
				possibilities[right].erase(impossible);
				
		# Up
		var up = Vector2i(placing.x,placing.y-1);
		if(placing.y > 0 && !cells_placed.has(up)):
			if(! cells_on_edge.has(up)):
				cells_on_edge.append(up);
			for impossible in get_impossible_neighbours(connections[tyle_type].has("up"),"down"):
				possibilities[up].erase(impossible);
		
		# Down
		var down = Vector2i(placing.x,placing.y+1);
		if(placing.y < height-1 && !cells_placed.has(down)):
			if(! cells_on_edge.has(down)):
				cells_on_edge.append(down);
			for impossible in get_impossible_neighbours(connections[tyle_type].has("down"),"up"):
				possibilities[down].erase(impossible);
	
	#Place food, cans, and seekers
	var eligibleList = []
	for cell in tile_map.get_used_cells_by_id(0,Vector2i(3,2)):
		eligibleList.append(cell)
	print(len(eligibleList))
	if len(eligibleList) > numberOfFood + numberOfCans + numberOfSeekers:
		for i in range(numberOfFood):
			print(i)
			var placeCell = eligibleList.pick_random()
			eligibleList.remove_at(eligibleList.find(placeCell,0))
			var scene = food.instantiate()
			scene.position = tile_map.map_to_local(placeCell)
			add_child(scene)
		for i in range(numberOfCans):
			var placeCell = eligibleList.pick_random()
			eligibleList.remove_at(eligibleList.find(placeCell,0))
			var scene = can.instantiate()
			scene.position = tile_map.map_to_local(placeCell)
			add_child(scene)
		for i in range(numberOfSeekers):
			var placeCell = eligibleList.pick_random()
			eligibleList.remove_at(eligibleList.find(placeCell,0))
			var scene = seeker.instantiate()
			scene.position = tile_map.map_to_local(placeCell)
			add_child(scene)
	else:
		print("Faulty generation")
		
