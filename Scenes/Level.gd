extends Node2D

@onready var tile_map = $TileMap
@onready var player = $Player
@onready var camera_2d = $Camera2D

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
var _current_level = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	_number_of_levels = GameData.get_number_of_levels()
	
	#for d in range(1, _number_of_levels + 1):
		#var ld = GameData.get_data_for_level(str(d))
		#print("%s: %s" % [d, ld.size()])

	_current_level = 24
	setup_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("escape"):
		_current_level += 1
		if _current_level > _number_of_levels:
			_current_level = 1
			
		setup_level()


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


func place_player_on_map(coord:Dictionary) -> void:
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
	tile_map.clear()
	var level_data = GameData.get_data_for_level(str(_current_level))
	var level_tiles = level_data.tiles
	var player_start = level_data.player_start
	
	for layer_name in LAYER_MAP.keys():
		add_layer_tiles(level_tiles[layer_name], layer_name)
	
	place_player_on_map(player_start)
	move_camera()
	
