extends Node2D

@onready var tile_map = $TileMap
@onready var player = $Player
@onready var camera_2d = $Camera2D
@onready var hud = $CanvasLayer/HUD
@onready var game_over_ui = $CanvasLayer/GameOverUi

const FLOOR_LAYER = 0
const WALL_LAYER = 1
const TARGET_LAYER = 2
const BOX_LAYER = 3

const SOURCE_ID = 0

const LAYER_KEY_FLOOR = "Floor"
const LAYER_KEY_WALLS = "Walls"
const LAYER_KEY_TARGETS = "Targets"
const LAYER_KEY_TARGET_BOXES = "TargetBoxes"
const LAYER_KEY_BOXES = "Boxes"

const LAYER_MAP = {
	LAYER_KEY_FLOOR: FLOOR_LAYER,
	LAYER_KEY_WALLS: WALL_LAYER,
	LAYER_KEY_TARGETS: TARGET_LAYER,
	LAYER_KEY_TARGET_BOXES: BOX_LAYER,
	LAYER_KEY_BOXES: BOX_LAYER
}

var _number_of_levels = 0
var _current_level:String = "0"
var _current_best = ScoreSync.NO_BEST
var _moving:bool = false
var _total_moves:int = 0
var _level_complete:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_number_of_levels = GameData.get_number_of_levels()
	SignalManager.on_level_selected.connect(on_level_selected)
	setup_level()


func on_level_selected(level:String):
	_current_level = level
	setup_level()


func level_complete():
	_level_complete = true
	SignalManager.on_level_complete.emit(_current_level, _total_moves, _current_best)
	game_over_ui.show()
	hud.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var move_direction = Vector2.ZERO
	
	if _moving:
		return
		
	#if Input.is_action_just_pressed("escape"):
		#ScoreSync.reset_scores()
		#print("Resetting scores")
		#
		
	if Input.is_action_just_pressed("reload"):
		setup_level()
		return
	
	if Input.is_action_just_pressed("exit"):
		GameManager.load_main_scene()

	if Input.is_action_just_pressed("right"):
		player.flip_h = false
		move_direction = Vector2.RIGHT
	
	if Input.is_action_just_pressed("left"):
		player.flip_h = true
		move_direction = Vector2.LEFT
	
	if Input.is_action_just_pressed("up"):
		move_direction = Vector2.UP

	if Input.is_action_just_pressed("down"):
		move_direction = Vector2.DOWN
	
	if _level_complete == false and move_direction != Vector2.ZERO:
		player_move(move_direction)


func get_player_tile() -> Vector2i:
	var player_offset = player.global_position - tile_map.global_position
	return player_offset / GameData.TILE_SIZE


func player_move(direction:Vector2i) -> void:
	_moving = true
	var player_tile = get_player_tile()
	var new_tile = player_tile + direction
	
	var can_move:bool = true
	var box_seen:bool = false

	if cell_is_wall(new_tile):
		can_move = false
		
	if cell_is_box(new_tile):
		box_seen = true
		can_move = box_can_move(new_tile, direction)
	
	if can_move:
		_total_moves += 1
		update_hud()
	
		if box_seen:
			move_box(new_tile, direction)
		
		place_player_on_map(new_tile)
		check_game_state()
	_moving = false


func update_hud() -> void:
	hud.set_moves_label(str(_total_moves))
	hud.set_level_label(_current_level)
	hud.set_best_label(str(ScoreSync.get_best_score(_current_level)))


func cell_is_wall(cell:Vector2i) -> bool:
	return cell in tile_map.get_used_cells(WALL_LAYER)


func cell_is_box(cell:Vector2i) -> bool:
	return cell in tile_map.get_used_cells(BOX_LAYER)


func cell_is_empty(cell:Vector2i) -> bool:
	return cell_is_wall(cell) == false and cell_is_box(cell) == false


func box_can_move(box_tile:Vector2i, direction:Vector2i) -> bool:
	var new_tile = box_tile + direction
	return cell_is_empty(new_tile)


func move_box(box_tile:Vector2i, direction:Vector2i) -> void:
	var dest = box_tile + direction
	tile_map.erase_cell(BOX_LAYER, box_tile)
	
	if dest in tile_map.get_used_cells(TARGET_LAYER):
		tile_map.set_cell(
			BOX_LAYER, dest, SOURCE_ID, 
			get_atlas_coord_for_layer_name(LAYER_KEY_TARGET_BOXES))
	else:
		tile_map.set_cell(
			BOX_LAYER, dest, SOURCE_ID, 
			get_atlas_coord_for_layer_name(LAYER_KEY_BOXES))


func check_game_state() -> void:
	for t in tile_map.get_used_cells(TARGET_LAYER):
		if cell_is_box(t) == false:
			return
	level_complete()


### LEVEL SETUP

func get_atlas_coord_for_layer_name(layer_name:String) -> Vector2i:
	match layer_name:
		LAYER_KEY_FLOOR:
			return Vector2i(randi_range(3, 8), 0)
		LAYER_KEY_WALLS:
			return Vector2i(2, 0)
		LAYER_KEY_TARGETS:
			return Vector2i(9, 0)
		LAYER_KEY_BOXES:
			return Vector2i(1, 0)
		LAYER_KEY_TARGET_BOXES:
			return Vector2i(0, 0)
	# should never get here
	return Vector2i.ZERO


func add_tile(tile_coord:Dictionary, layer_name:String) -> void:
	var layer_number = LAYER_MAP[layer_name]
	var coord_vector:Vector2i = Vector2i(tile_coord.x, tile_coord.y)
	var atlas_vector:Vector2i = get_atlas_coord_for_layer_name(layer_name)
	
	tile_map.set_cell(layer_number, coord_vector, SOURCE_ID, atlas_vector)


func add_layer_tiles(layer_tiles:Array, layer_name:String) -> void:
	for tile in layer_tiles:
		add_tile(tile.coord, layer_name)


func place_player_on_map(coord:Vector2) -> void:
	var new_pos = Vector2(
		coord.x * GameData.TILE_SIZE, 
		coord.y * GameData.TILE_SIZE) + tile_map.global_position
	player.global_position = new_pos

func move_camera() -> void:
	var tmr = tile_map.get_used_rect()
	
	var tile_map_start_x = tmr.position.x * GameData.TILE_SIZE
	var tile_map_end_x = tmr.size.x * GameData.TILE_SIZE + tile_map_start_x
	
	var tile_map_start_y = tmr.position.y * GameData.TILE_SIZE
	var tile_map_end_y = tmr.size.y * GameData.TILE_SIZE + tile_map_start_y
	
	var mid_x = tile_map_start_x + (tile_map_end_x - tile_map_start_x) / 2
	var mid_y = tile_map_start_y + (tile_map_end_y - tile_map_start_y) / 2

	camera_2d.position = Vector2(mid_x, mid_y)


func setup_level() -> void:
	var level = GameManager.get_level_selected()
	var level_data = GameData.get_data_for_level(level)
	_current_level = level
	
	tile_map.clear()
	var level_tiles = level_data.tiles
	var player_start = level_data.player_start

	for layer_name in LAYER_MAP.keys():
		add_layer_tiles(level_tiles[layer_name], layer_name)
	
	place_player_on_map(Vector2(player_start.x, player_start.y))
	player.flip_h = false
	
	_total_moves = 0
	_level_complete = false
	_current_best = ScoreSync.get_best_score(str(level))
	update_hud()
	move_camera()

