extends Node

const LEVEL_DATA_PATH:String = "res://data/level_data.json"
const TILE_SIZE:int = 32

var _level_data:Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	if !load_level_data():
		return



func load_level_data() -> bool:
	var file = FileAccess.open(LEVEL_DATA_PATH, FileAccess.READ)
	if !file:
		print("ERROR! Unable to read resource: ", LEVEL_DATA_PATH)
		return false
	_level_data = JSON.parse_string(file.get_as_text())
	print("Loaded %s levels into _level_data." % _level_data.size())
	return true


func get_data_for_level(level:String) -> Dictionary:
	if level not in _level_data.keys():
		print("Level data not found for level ", level)
		return {}
		
	return _level_data[level]


func get_number_of_levels() -> int:
	return _level_data.size()

