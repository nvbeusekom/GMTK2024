extends Node2D

@export var noise : NoiseTexture2D;
@export var width = 5;
@export var height = 5;

@onready var tile_map = $NavigationRegion2D/TileMapLayer
@onready var navigation_region = $NavigationRegion2D

var numberOfSeekers = 10
var numberOfFood = 50
var numberOfCans = 50
var food = load("res://Scenes/food.tscn")
var seeker = load("res://Scenes/seeker.tscn")
var can = load("res://Scenes/can.tscn")
var pause_node = null
var pauseScreen = load("res://Scenes/pause_screen.tscn")
var game_over_node = null
var game_over_screen = load("res://Scenes/game_over.tscn")
var destroySFX = load("res://Scenes/shelf_destroy_sfx.tscn")
var mainMenu = load("res://Scenes/title_screen.tscn")
var player = load("res://Scenes/player.tscn")
var HUD = load("res://Scenes/HUD.tscn")
var destroying_shelves = false;
var blackExtend = 20
var maxOffset = 20

var music_offset = 0;
var sound_offset = 0;

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
var horizontal_gap3_atlas = Vector2i(0,4);
var vertical_gap3_atlas = Vector2i(1,4);
var empty_atlas = Vector2i(3,2);

var destroyed_atlas = Vector2i(2,4);

var top_left_wall_atlas = Vector2i(4,3);
var top_right_wall_atlas = Vector2i(5,3);
var bot_left_wall_atlas = Vector2i(6,3);
var bot_right_wall_atlas = Vector2i(7,3);
var top_wall_atlas = Vector2i(6,2);
var bot_wall_atlas = Vector2i(4,2);
var left_wall_atlas = Vector2i(5,2);
var right_wall_atlas = Vector2i(7,2);
var full_wall = Vector2i(2,4);
var black_atlas = Vector2i(3,4);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	open_main_menu();

func _exit() -> void:
	get_tree().quit()

func _game_start() -> void:
	if $TitleScreen != null:
		if $TitleScreen/CanvasLayer/OptionButton.selected == 0:
			numberOfSeekers = 4;
			numberOfFood = 50;
			numberOfCans = 20;
		if $TitleScreen/CanvasLayer/OptionButton.selected == 1:
			numberOfSeekers = 7;
			numberOfFood = 35;
			numberOfCans = 35;
		if $TitleScreen/CanvasLayer/OptionButton.selected == 2:
			numberOfSeekers = 10;
			numberOfFood = 20;
			numberOfCans = 50;
		$TitleScreen.queue_free()
	var scene = player.instantiate()
	scene.global_position = Vector2(45,45)
	add_child(scene)
	add_child(HUD.instantiate())
	generate();
	bake_nav();
	if $pauseScreen != null:
		unpause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(destroying_shelves):
		var pos = Vector2i(floor($Player/CharacterBody2D.global_position.x/64),floor($Player/CharacterBody2D.global_position.y/64))
		var tile = tile_map.get_cell_atlas_coords(pos);
		if(tile != empty_atlas && tile != destroyed_atlas):
			tile_map.set_cell(pos,source_id,destroyed_atlas);
			var scene = destroySFX.instantiate()
			scene.global_position = pos
			add_child(scene)

func open_main_menu():
	var scene = mainMenu.instantiate()
	add_child(scene)
	$TitleScreen/CanvasLayer/newGameButton.pressed.connect(_game_start)
	$TitleScreen/CanvasLayer/quitButton.pressed.connect(_exit)

func recursive_pause(node):
	for child in node.get_children():
		if child.has_method("pause"):
			child.pause()
		recursive_pause(child) 
		
func recursive_unpause(node):
	for child in node.get_children():
		if child.has_method("unpause"):
			child.unpause()
		recursive_unpause(child) 

func pause():
	#get_tree().paused = true
	recursive_pause(self);
	pause_node = pauseScreen.instantiate()
	add_child(pause_node)

func unpause():
	#get_tree().paused = false
	recursive_unpause(self);
	pause_node.queue_free() 

func big_boy_time():
	tile_map.collision_enabled = false;
	destroying_shelves = true;

func _input(event):
	if Input.is_action_pressed("pause"):
		if pause_node == null:
			pause()
		else:
			unpause()
			

func game_over():
	print("game over");
	recursive_pause(self);
	
	if get_tree().get_nodes_in_group("player")[0].get_node("MusicChase").playing:
		get_tree().get_nodes_in_group("player")[0].get_node("MusicChase").stop()
	if get_tree().get_nodes_in_group("player")[0].get_node("MusicSafe").playing:
		get_tree().get_nodes_in_group("player")[0].get_node("MusicSafe").stop()
	if !get_tree().get_nodes_in_group("player")[0].get_node("GameOver").playing:
		get_tree().get_nodes_in_group("player")[0].get_node("GameOver").play()
	
	game_over_node = game_over_screen.instantiate()
	add_child(game_over_node);

func clear_game():
	get_tree().get_nodes_in_group("camera")[0].global_position = Vector2(45,45)
	#player.score = 0
	for node in get_tree().get_nodes_in_group("seeker"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group("delete"):
		node.queue_free()

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
	horizontal_gap3_atlas: ["left","right"],
	vertical_gap3_atlas: ["up","down"],
	empty_atlas: []
}

var weights = {
	horizontal_atlas: 5,
	vertical_atlas: 5,
	left_down_atlas: 3,
	left_up_atlas: 3,
	right_up_atlas: 3,
	right_down_atlas: 3,
	t_down_atlas: 2,
	t_left_atlas: 2,
	t_up_atlas: 2,
	t_right_atlas: 2,
	cross_atlas: 1,
	left_atlas: 2,
	up_atlas: 2,
	right_atlas: 2,
	down_atlas: 2,
	horizontal_gap1_atlas: 3,
	vertical_gap1_atlas: 3,
	horizontal_gap2_atlas: 2,
	vertical_gap2_atlas: 2,
	horizontal_gap3_atlas: 1,
	vertical_gap3_atlas: 1,
	empty_atlas: 20
}

func get_impossible_neighbours(contains,direction):
	var neighbours = []
	for key in connections.keys():
		if(contains != connections[key].has(direction)):
			neighbours.append(key);
	return neighbours;

func get_randomized_tile(possibilities):
	var randomizerList = []
	for possibility in possibilities:
		var counter = weights[possibility]
		while counter > 0:
			randomizerList.append(possibility)
			counter -= 1
	return randomizerList.pick_random()

func bake_nav():
	var nav_polygon = NavigationPolygon.new();
	var bounding_outline = PackedVector2Array([Vector2i(0, 0), Vector2i(0, height*64), Vector2i(width*64, height*64), Vector2i(height*64, 0)]);
	nav_polygon.add_outline(bounding_outline);
	navigation_region.navigation_polygon = nav_polygon;
	navigation_region.bake_navigation_polygon(false);
	
func generate():
	# First place walls around the level and remove connections to the wall
	tile_map.set_cell(Vector2i(-1,-1),source_id,top_left_wall_atlas);
	tile_map.set_cell(Vector2i(width,-1),source_id,top_right_wall_atlas);
	tile_map.set_cell(Vector2i(-1,height),source_id,bot_left_wall_atlas);
	tile_map.set_cell(Vector2i(width,height),source_id,bot_right_wall_atlas);
	
	for i in range(width):
		tile_map.set_cell(Vector2i(i,-1),source_id,top_wall_atlas);
		tile_map.set_cell(Vector2i(i,height),source_id,bot_wall_atlas);
	for i in range(height):
		tile_map.set_cell(Vector2i(-1,i),source_id,left_wall_atlas);
		tile_map.set_cell(Vector2i(width,i),source_id,right_wall_atlas);
	
	for i in range(-blackExtend,-1): #left
		for j in range(-blackExtend,height + 1 + blackExtend):
			tile_map.set_cell(Vector2i(i,j),source_id,black_atlas)
	for i in range(width + 1,width + 1 + blackExtend): #right
		for j in range(-blackExtend,height + 1 + blackExtend):
			tile_map.set_cell(Vector2i(i,j),source_id,black_atlas)
	for i in range(-blackExtend,width + 1 + blackExtend): #up
		for j in range(-blackExtend,-1):
			tile_map.set_cell(Vector2i(i,j),source_id,black_atlas)
	for i in range(-blackExtend,width + 1 + blackExtend): #down
		for j in range(height + 1,height + 1 + blackExtend):
			tile_map.set_cell(Vector2i(i,j),source_id,black_atlas)
	
	# Add colision polygon around map
	var surrounding_polygon = CollisionPolygon2D.new();
	surrounding_polygon.polygon = PackedVector2Array([Vector2(-16,-16),Vector2(width*64.75,-16),Vector2(width*64.75,height*64.75),Vector2(-16,height*64.75),Vector2(-16,-128),Vector2(-128,-128),Vector2(-128,height*66),Vector2(width*66,height*66),Vector2(width*66,-128),Vector2(-16,-128)]);
	$StaticBody2D.add_child(surrounding_polygon);
	
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
											horizontal_gap3_atlas,
											vertical_gap3_atlas,
											empty_atlas];
	
	for i in range(width):
		for tile in get_impossible_neighbours(false,"up"):
			possibilities[Vector2i(i,0)].erase(tile);
		for tile in get_impossible_neighbours(false,"down"):
			possibilities[Vector2i(i,height-1)].erase(tile);
	for i in range(width):
		for tile in get_impossible_neighbours(false,"left"):
			possibilities[Vector2i(0,i)].erase(tile);
		for tile in get_impossible_neighbours(false,"right"):
			possibilities[Vector2i(width-1,i)].erase(tile);
	
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
		
		var tyle_type = get_randomized_tile(possibilities[placing])
		#var tyle_type = possibilities[placing].pick_random();
		#if(possibilities[placing].has(empty_atlas) && randf() < 0.7):
		#	tyle_type = empty_atlas;
		
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
		if (tile_map.map_to_local(cell) - get_tree().get_nodes_in_group("player")[0].position).length() > 250:
			eligibleList.append(cell)
	if len(eligibleList) > numberOfFood + numberOfCans + numberOfSeekers:
		for i in range(numberOfFood):
			var placeCell = eligibleList.pick_random()
			eligibleList.remove_at(eligibleList.find(placeCell,0))
			var scene = food.instantiate()
			scene.position = Vector2(tile_map.map_to_local(placeCell).x + randf_range(-maxOffset,maxOffset),tile_map.map_to_local(placeCell).y + randf_range(-maxOffset,maxOffset))
			add_child(scene)
		for i in range(numberOfCans):
			var placeCell = eligibleList.pick_random()
			eligibleList.remove_at(eligibleList.find(placeCell,0))
			var scene = can.instantiate()
			scene.position = Vector2(tile_map.map_to_local(placeCell).x + randf_range(-maxOffset,maxOffset),tile_map.map_to_local(placeCell).y + randf_range(-maxOffset,maxOffset))
			add_child(scene)
		for i in range(numberOfSeekers):
			var placeCell = eligibleList.pick_random()
			eligibleList.remove_at(eligibleList.find(placeCell,0))
			var scene = seeker.instantiate()
			scene.position = Vector2(tile_map.map_to_local(placeCell).x + randf_range(-maxOffset,maxOffset),tile_map.map_to_local(placeCell).y + randf_range(-maxOffset,maxOffset))
			add_child(scene)
	else:
		print("Faulty generation, too few empty tiles")
		
