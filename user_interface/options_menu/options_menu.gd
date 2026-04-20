extends abstract_options

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

# Function responsible for opening options menu. 
# When opening options menu, we do not open it as a seperate scene. 
# We hide the contents of the existing scene (from_menu: Control = null) and show the options menu.
func open(from_menu: Control = null) -> void:
	previous_menu = from_menu
	previous_menu.hide()
	show()

# Show the contents of the scene, hide options menu.
func close() -> void:
	hide()

	if previous_menu:
		previous_menu.show()

func _on_back_button_pressed() -> void:
	close()
