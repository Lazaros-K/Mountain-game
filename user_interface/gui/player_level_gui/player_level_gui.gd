extends Control

# Referencing the player character so we can access player position on y axis.
@export var player_character: CharacterBody2D
@onready var heart_label: hearts = $HeartBar
@onready var score_label: score_counter = $ScoreCounter

var meters: int = 0
var score: String = "meters: 0"
var init_pos: float 
var uids: scene_uid

# We get the initial position se we can subtract it from the position every time.
# If initial position 10, we want it to be 0, so we subtract 10 from position so it starts from 0..
func _ready() -> void:
	init_pos = player_character.global_position.y 

# To convert pixels to tiles, we divide it by 16. And we discard the decimal.
func _process(_delta: float) -> void:
	meters = floor((-(player_character.global_position.y - init_pos)) / 16)
	score = "meters: " + str(int(meters))
	# We update the score ui here.
	score_label.update_score(score)
	# Pass the score in the global var so we can access it in the game over screen.
	GlobalScore.score = meters

# Goes to "game over" screen when character dies. Press "K" to test.
func die() -> void:
	get_tree().change_scene_to_file(uids.END_SCREEN)

# Simple heart bar. Press "T" to take damage, "H" to heal.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		heart_label.receive_damage()
	if event.is_action_pressed("test2"):
		heart_label.heal()
	if event.is_action_pressed("test3"):
		die()
