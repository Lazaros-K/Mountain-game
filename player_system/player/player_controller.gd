# Reads input and translates to PlayerCommand.
class_name PlayerController
extends Node

@export var player: Player

const ACTION_LEFT     :String= "left"
const ACTION_RIGHT    :String= "right"
const ACTION_JUMP     :String= "jump"
const ACTION_AIR_UP   :String= "up"
const ACTION_AIR_DOWN :String= "down"

var _cmd: PlayerCommand = PlayerCommand.new()

# Latched in _unhandled_input so no press is ever dropped between physics ticks.
var q_latch: bool = false
var e_latch: bool = false
# kaleitai aytomata apo to input system tis godot
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("wall_jump_left"):
		q_latch = true
	if event.is_action_pressed("wall_jump_right"):
		e_latch = true
#kaleitai aytomata se kathe frame 
func _physics_process(_delta: float) -> void:
	_read_input()
	player.apply_command(_cmd)
	# Clear latches after command is sent — one fire per press guaranteed.
	q_latch = false
	e_latch = false
#arxikopoiei tis times kai lamvanei meta tis kanonikes times
func _read_input() -> void:
	_cmd.move_direction       = 0.0
	_cmd.jump_pressed         = false
	_cmd.air_horizontal       = 0.0
	_cmd.air_vertical         = 0.0
	_cmd.press_away_from_wall = false
	_cmd.wall_jump_left       = false
	_cmd.wall_jump_right      = false

	_cmd.move_direction = Input.get_axis(ACTION_LEFT, ACTION_RIGHT)
	_cmd.jump_pressed   = Input.is_action_just_pressed(ACTION_JUMP)
	_cmd.air_horizontal = _cmd.move_direction
	_cmd.air_vertical   = Input.get_axis(ACTION_AIR_UP, ACTION_AIR_DOWN)

	_cmd.wall_jump_left  = q_latch
	_cmd.wall_jump_right = e_latch

	var wall_side :int= player.wall_side
	if wall_side != 0:
		_cmd.press_away_from_wall = (
			(wall_side == -1 and _cmd.move_direction > 0.0) or
			(wall_side == +1 and _cmd.move_direction < 0.0)
		)
