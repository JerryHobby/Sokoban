extends Node

const level_scene:PackedScene = preload("res://Scenes/Level.tscn")
const main_scene:PackedScene = preload("res://Scenes/main.tscn")


var _level_selected:String


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_level_selected.connect(on_level_selected)


func get_level_selected() -> String:
	return _level_selected


func on_level_selected(level:String) -> void:
	_level_selected = level
	get_tree().change_scene_to_packed(level_scene)
	

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(main_scene)
	
