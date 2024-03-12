extends NinePatchRect
@onready var level_label = $LevelLabel
@onready var best_label = $ScoreBox/BestLabel
@onready var score_box = $ScoreBox

const GREEN_TEXTURE = preload("res://assets/green_panel.png")
var _level_number:String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	level_label.text = _level_number
	#SignalManager.on_level_complete.connect(on_level_complete)
	var best = ScoreSync.get_best_score(_level_number)
	
	if best != ScoreSync.NO_BEST:
		best_label.text = str(best)
		score_box.show()
	else:
		score_box.hide()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_level_number(level:String) -> void:
	_level_number = level

#func on_level_complete(level, points, best):
	#print("Level: %s - Score: %s" % [level, points])
	#check_mark.show()


func _on_gui_input(event:InputEvent):
	if event.is_action_pressed("select"):
		texture = GREEN_TEXTURE
		SignalManager.on_level_selected.emit(_level_number)
