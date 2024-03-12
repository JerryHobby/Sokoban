extends CanvasLayer

const button_scene:PackedScene = preload("res://Scenes/level_button.tscn")
const LEVEL_ROWS:int = 5
const LEVEL_COLS:int = 8

@onready var grid_container = $MC/VB/GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_grid()


func setup_grid() -> void:
	var grid_size = LEVEL_COLS * LEVEL_ROWS
	var levels = GameData.get_number_of_levels()
	
	grid_container.columns = LEVEL_COLS
	for level in range(grid_size):
		if level >= levels:
			break
			
		var lbs = button_scene.instantiate()
		lbs.set_level_number(str(level + 1))
		grid_container.add_child(lbs)



