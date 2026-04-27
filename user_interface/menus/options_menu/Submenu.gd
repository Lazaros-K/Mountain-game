class_name Submenu
extends Control

var previous_menu: Control = null

# Function responsible for opening options menu. 
# When opening options menu, we do not open it as a seperate scene. 
# We hide the contents of the existing scene (from_menu: Control = null) and show the options menu
func open(from_menu: Control = null) -> void:
	previous_menu = from_menu
	previous_menu.hide()
	show()

# Show the contents of the scene, hide options menu.
func close() -> void:
	hide()
	previous_menu.show()
