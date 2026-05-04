extends Node
class_name GlobalScoreNode

var current_run_score: int = 0
var high_score: int = 0

func update_high_score() -> void:
	if current_run_score > high_score:
		high_score = current_run_score
