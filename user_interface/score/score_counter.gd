extends CanvasLayer

@export var test_character_path: NodePath
@onready var test_character = get_node(test_character_path)
@onready var label: Label = $Label

var meters = 0

func _ready():
	label.text = "meters: 0"

func _process(delta: float) -> void:
	meters = -test_character.global_position.y
	label.text = "meters: " + str(int(meters))
