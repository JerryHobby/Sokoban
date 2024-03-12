extends Control
@onready var moves_label = $MC/NP/MarginContainer/VBoxContainer/MovesLabel
@onready var best_label = $MC/NP/MarginContainer/VBoxContainer/BestLabel
@onready var record_label = $MC/NP/MarginContainer/VBoxContainer/RecordLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_level_complete.connect(on_level_complete)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_level_complete(level:String, score:int, current_best:int) -> void:
	var best = ScoreSync.get_best_score(level)
	moves_label.text = "Moves %s" % score
	
	if score < current_best:
		best = str(score)
		record_label.show()

	best_label.text = "Best Score %s" % best

