extends CanvasLayer

@export var test_character_path: NodePath
@onready var test_character: CharacterBody2D = get_node(test_character_path)
@onready var label: Label = $Label

var meters: int = 0

func _ready() -> void:
	label.text = "meters: 0"

func _process(_delta: float) -> void:
	meters = -int(test_character.global_position.y)
	label.text = "meters: " + str(int(meters))
