extends Control
class_name endScreen

@onready var highscoreText: Label = $VBoxContainer/Highscore
@onready var scoreText: Label = $VBoxContainer/Score
var score: int

func _ready() -> void:
	scoreText.text = "score: " + str(global_score.score)

# Reload level scene when play again pressed
func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://user_interface/loading_screen/loading_screen.tscn")

# Change to scene main menu when quit pressed.
func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://user_interface/main_menu/main_menu.tscn")
