class_name score_counter
extends CanvasLayer

@onready var label: Label = $Label

var meters: int = 0
var init_pos: float

func _ready() -> void:
	label.text = "Default"

# Just updates the label
func update_score(score: String) -> void:
	label.text = score
