extends Control
class_name endScreen

@onready var highscoreText: Label = $VBoxContainer/Highscore
@onready var scoreText: Label = $VBoxContainer/Score
var score: int
var uids: scene_uid

func _ready() -> void:
	scoreText.text = "score: " + str((GlobalScore as GlobalScoreNode).current_run_score) 
	highscoreText.text = "Highscore: " + str((GlobalScore as GlobalScoreNode).high_score) 

# Reload level scene when play again pressed
func _on_play_again_pressed() -> void:
	(GlobalScore as GlobalScoreNode).current_run_score = 0
	get_tree().change_scene_to_file(uids.LOADING_SCREEN)

# Change to scene main menu when quit pressed.
func _on_quit_pressed() -> void:
	(GlobalScore as GlobalScoreNode).current_run_score = 0
	get_tree().change_scene_to_file(uids.MAIN_MENU)
