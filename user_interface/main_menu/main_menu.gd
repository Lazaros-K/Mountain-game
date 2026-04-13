extends Control

@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var options_menu: Control = $OptionsMenu

@export var starting_scene: String

func _ready() -> void:
	menu_buttons.visible = true

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(starting_scene)

func _on_options_pressed() -> void:
	options_menu.open(menu_buttons)

func _on_exit_pressed() -> void:
	get_tree().quit()
