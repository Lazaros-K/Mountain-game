extends Submenu

@onready var screen_mode_b: CheckButton = $Options/VBoxContainer/ScreenModeB
@onready var seed_line_edit: LineEdit = $Options/VBoxContainer/SeedContainer/LineEdit


func _ready() -> void:
	hide()
	
# Makes sure fullscreen toggle is correct according to selected window mode.
	var mode :int = DisplayServer.window_get_mode()
	var is_fullscreen :bool = (
		mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)
	
	screen_mode_b.set_pressed_no_signal(is_fullscreen)
	
	seed_line_edit.text_changed.connect(_on_seed_text_changed)

func _on_seed_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		SeedManager.use_custom_seed = false
	else:
		SeedManager.use_custom_seed = true
		SeedManager.custom_seed = new_text.hash()

func _on_back_button_pressed() -> void:
	close()
