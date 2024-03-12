extends Node


const SCORE_FILE:String = "user://score.dat"
const NO_BEST:int = 10000

var _best_scores:Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_level_complete.connect(on_level_complete)
	load_scores()


func load_scores() -> void:
	if FileAccess.file_exists(SCORE_FILE) == false:
		return
	var file = FileAccess.open(SCORE_FILE, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	if data:
		_best_scores = data
	file.close()


func reset_scores() -> void:
	_best_scores = {}
	save_scores()


func save_scores() -> void:
	var file = FileAccess.open(SCORE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(_best_scores))
	file.close()


func on_level_complete(level:String, score:int, _best:int) -> void:
	if level in _best_scores.keys():
		if score < _best_scores[level]:
			_best_scores[level] = score
	else:
		_best_scores[level] = score
	
	save_scores()


func get_best_score(level:String) -> int:
	if level in _best_scores.keys():
		return _best_scores[level]
	else:
		return NO_BEST
