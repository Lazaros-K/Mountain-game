#wall grip logic--same logic as controller/player 
class_name WallGripHandler
extends Node

signal gripped(data: WallData)
signal grip_state_changed(new_state: GripState)
signal grip_lost()

enum GripState{
	NONE,
	GRIPPED,#100% grip
	LOOSENED,#counting down to slide
	SLIDING#gravity is pulling
}

const IMMEDIATE_SLIDE_THRESHOLD: float = 35.0
const MAX_HOLD_TIME: float = 3.0
const MIN_HOLD_TIME: float = 0.2
#how quickly velocity cancels on grip contact
const GRIP_VELOCITY_DAMPING: float = 8000.0
const SLIDE_GRAVITY_SCALE: float = 0.18

var state: GripState = GripState.NONE
var current_wall: WallData = null
var _hold_timer: float = 0.0
var _player: Player = null

func _ready() -> void:
	_player = get_parent() as Player
	if _player == null:
		push_error("WallGripHandler must be a child of a player") 

#counts down _hold_timer when LOOSENED and enters SLIDING when it expires
func _physics_process(delta: float) ->void:
	if state == GripState.NONE:
		return
	if _player.is_on_floor():
		_release_grip()
		return
	if not _player.is_on_wall():
		_release_grip()
		return
	if state == GripState.LOOSENED:
		_hold_timer-=delta
		if _hold_timer<=0.0:
			_enter_sliding()

#Attempts to start a grip: creates a WallData
#Called by Player.apply_command when airborne and touching a wall
func try_grip(wall_side: int, surface_grip: float) -> void:
	if state != GripState.NONE:
		return 
	if surface_grip<=0.0:
		return 
	var data := WallData.new()
	data.grip_power = surface_grip
	data.wall_side = wall_side
	current_wall = data
	
	if surface_grip < IMMEDIATE_SLIDE_THRESHOLD:
		state = GripState.SLIDING
		emit_signal("gripped", data)
		emit_signal("grip_state_changed", GripState.SLIDING)
		return
	
	state = GripState.GRIPPED
	emit_signal("gripped",data)
	emit_signal("grip_state_changed",GripState.GRIPPED)

#Transitions GRIPPED → LOOSENED and calculates how long the player can hang before sliding
#Called by Player.apply_command when cmd.press_away_from_wall is true
func loosen_grip() -> void:
	if state != GripState.GRIPPED:
		return
	state = GripState.LOOSENED
	#calc hold time based on grip value
	var t: float = inverse_lerp(
		IMMEDIATE_SLIDE_THRESHOLD,
		90.0,
		current_wall.grip_power
	)
	t = clamp(t,0.0,1.0)
	_hold_timer = lerp(MIN_HOLD_TIME, MAX_HOLD_TIME, t)
	emit_signal("grip_state_changed", GripState.LOOSENED)

#Immediately calls _release_grip to clear grip on any wall jump
func release_on_jump() -> void:
	_release_grip()

#Returns GRIP_VELOCITY_DAMPING if GRIPPED or LOOSENED, otherwise 0
#Called by Player._apply_grip_damping
func get_velocity_damping() ->float:
	if state == GripState.GRIPPED or state == GripState.LOOSENED:
		return GRIP_VELOCITY_DAMPING
	return 0.0

#emits grip_state_changed
#Called by _physics_process when the LOOSENED hold timer runs out
func _enter_sliding() -> void:
	state =GripState.SLIDING
	emit_signal("grip_state_changed", GripState.SLIDING)

#Resets state to NONE, clears current_wall and timer, emits grip_lost and grip_state_changed
#Called by _physics_process and release_on_jump
func _release_grip() -> void:
	if state == GripState.NONE:
		return
	state = GripState.NONE
	current_wall = null
	_hold_timer = 0.0
	emit_signal("grip_lost")
	emit_signal("grip_state_changed", GripState.NONE)

#Returns SLIDE_GRAVITY_SCALE (0.18) when SLIDING, 1.0 otherwise
#Called by Player.apply_command in the SLIDING branch
func get_gravity_scale() -> float:
	if state == GripState.SLIDING:
		return SLIDE_GRAVITY_SCALE
	return 1.0
