extends Control


# Reload level scene when play again pressed
func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://user_interface/test_scene/test_level.tscn")

# Change to scene main menu when quit pressed.
func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://user_interface/main_menu/main_menu.tscn")
