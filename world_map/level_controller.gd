extends Node2D

@onready var player_character: CharacterBody2D = $test_character
@onready var map_generator: MapGenerator = $MapGenerator
@onready var start_fragment: MapFragment = $start  
@onready var sun_anim: AnimatedSprite2D = player_character.get_node_or_null("sun") as AnimatedSprite2D                  
@onready var heart_bar: hearts = $Player_GUI/HeartBar
@onready var player_gui: gui = $Player_GUI

func _ready() -> void:
	@warning_ignore("unsafe_method_access") # it is not unsafe...
	player_character.c_setup_character(map_generator,start_fragment)
	@warning_ignore("unsafe_property_access", "unsafe_method_access")
	player_character.damage.connect(heart_bar.receive_damage)
	@warning_ignore("unsafe_property_access", "unsafe_method_access")
	player_character.heal.connect(heart_bar.heal)
	@warning_ignore("unsafe_property_access", "unsafe_method_access")
	player_character.died.connect(player_gui.die)
