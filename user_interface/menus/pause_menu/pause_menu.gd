extends CanvasLayer

@onready var control: Control = $Control
@onready var options_menu: Submenu = $OptionsMenu

func _ready() -> void:
	visible = false
	control.hide()
	options_menu.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		open_pause();
	
# Pause level scene, show pause menu.
func open_pause() -> void:
	visible = true
	control.show()
	get_tree().paused = true

func close_pause() -> void:
	control.hide()
	visible = false
	get_tree().paused = false

func _on_resume_pressed() -> void:
	close_pause()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file(scene_uid.MAIN_MENU)

# Opens options menu and passes the contents of level scene.
func _on_options_pressed() -> void:
	options_menu.open(control)
