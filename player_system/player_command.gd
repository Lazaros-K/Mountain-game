#plain container that passes datat from the controller to the player every physics frame
class_name PlayerCommand
extends Resource

#horizontal intent [-1.0,1.0] -> left,right
var move_direction: float = 0.0

#true only when jyst pressed not held
var jump_pressed: bool = false

#same as move but less impact 
var air_horizontal: float = 0.0
var air_vertical: float = 0.0
