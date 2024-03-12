extends Control
@onready var level_label = $MC/VBoxContainer/LevelBox/LevelLabel
@onready var moves_label = $MC/VBoxContainer/MovesBox/MovesLabel
@onready var best_label = $MC/VBoxContainer/BestBox/BestLabel

@onready var best_box = $MC/VBoxContainer/BestBox


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_level_label(label:String) -> void:
	level_label.text = label


func set_moves_label(label:String) -> void:
	moves_label.text = label


func set_best_label(label:String) -> void:
	if label == str(ScoreSync.NO_BEST):
		best_box.hide()
		return

	best_box.show()
	best_label.text = label
