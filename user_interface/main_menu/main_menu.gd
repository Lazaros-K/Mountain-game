extends Control

@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var options_menu: Control = $OptionsMenu

@export var starting_scene: String
var uids: scene_uid

# Make menu buttons visible on default.
func _ready() -> void:
	menu_buttons.visible = true

# Start test level when Start pressed.
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(uids.LOADING_SCREEN)

# Open options menu when options button pressed.
func _on_options_pressed() -> void:
	options_menu.open(menu_buttons)

# Exit the program when exit pressed.
func _on_exit_pressed() -> void:
	get_tree().quit()
