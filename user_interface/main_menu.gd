extends Control

@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var options: Panel = $Options

func _ready():
	menu_buttons.visible = true
	options.visible = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://world_map/tile_system/test/test_maps/test_level.tscn")


func _on_options_pressed() -> void:
	menu_buttons.visible = false
	options.visible = true


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_ready()
