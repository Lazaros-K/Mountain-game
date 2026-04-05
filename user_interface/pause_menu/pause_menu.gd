extends CanvasLayer
#test
func _ready() -> void:
	visible = false
	get_tree().paused = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true

func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_restart_pressed() -> void:
	visible = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://user_interface/main_menu.tscn")
