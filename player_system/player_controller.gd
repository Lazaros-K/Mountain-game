#reads input and translates to playercommand
class_name PlayerController
extends Node

@export var player: Player

const ACTION_LEFT :="left"
const ACTION_RIGHT :="right"
const ACTION_JUMP :="jump"
const ACTION_AIR_UP :="up"
const ACTION_AIR_DOWN :="down"

var _cmd: PlayerCommand = PlayerCommand.new()

func _physics_process(_delta: float) ->void:
	print("controller running, player=", player)
	if player == null:
		push_warning("PlayerController: no player node assigned")
		return
	
	_read_input()
	player.apply_command(_cmd)

func _read_input() -> void:
	#reset command to neutral state before reading this frame
	_cmd.move_direction = 0.0
	_cmd.jump_pressed = false
	_cmd.air_horizontal = 0.0
	_cmd.air_vertical = 0.0
	_cmd.press_away_from_wall = false
	
	_cmd.move_direction = Input.get_axis(ACTION_LEFT,ACTION_RIGHT)
	_cmd.jump_pressed = Input.is_action_just_pressed("jump")
	_cmd.air_horizontal = _cmd.move_direction
	_cmd.air_vertical = Input.get_axis(ACTION_AIR_UP,ACTION_AIR_DOWN)
	
	var wall_side := player._wall_side
	if wall_side != 0:
		_cmd.press_away_from_wall=(
			(wall_side == -1 and _cmd.move_direction > 0.0) or 
			(wall_side == +1 and _cmd.move_direction < 0.0)
		)
