extends Control

@onready var back_button: Button = $Options/BackButton
@onready var screen_mode_b: CheckButton = $Options/VBoxContainer/ScreenModeB


var previous_menu: Node = null 

func _ready() -> void:
	hide()
	
	var mode := DisplayServer.window_get_mode()
	var is_fullscreen := (
		mode == DisplayServer.WINDOW_MODE_FULLSCREEN or 
		mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)
	
	screen_mode_b.set_pressed_no_signal(is_fullscreen)

func open(from_menu: Node) -> void:
	previous_menu = from_menu
	from_menu.hide()
	show()

func _on_back_button_pressed() -> void:
	hide()
	previous_menu.show()
