extends Submenu

@onready var screen_mode_b: CheckButton = $Options/VBoxContainer/ScreenModeB


func _ready() -> void:
	hide()
	
# Makes sure fullscreen toggle is correct according to selected window mode.
	var mode :int = DisplayServer.window_get_mode()
	var is_fullscreen :bool = (
		mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)
	
	screen_mode_b.set_pressed_no_signal(is_fullscreen)

func _on_back_button_pressed() -> void:
	close()
