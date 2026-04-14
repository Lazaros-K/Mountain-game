extends HSlider
# Section responsible for the "Music" slider.

@export var audio_bus_name: String
@onready var sfx_slider: HSlider = $"../../HBoxContainer2/SFXSlider"


var audio_bus_id: int

# Slider always matches the volume of Music when options menu is reloaded.
func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	if audio_bus_id == -1:
		push_error("Bus not found: " + audio_bus_name)
		return
	set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(audio_bus_id)))

# Change to linear so volume change is smooth.
func _on_value_changed(val: float) -> void:
	var db: float = linear_to_db(val)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
