extends Node2D

@onready var player_character: CharacterBody2D = $test_character
@onready var map_generator: MapGenerator = $MapGenerator
@onready var start_fragment: MapFragment = $snow1

func _ready() -> void:
	@warning_ignore("unsafe_method_access") # it is not unsafe...
	player_character.c_setup_character(map_generator,start_fragment)
