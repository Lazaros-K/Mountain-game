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
#how long the player stays completely still before starting to slide
#scales with grip_power: strong surface = longer hold, weak = shorter
#for GRIPPED state
const MAX_GRIP_FATIGUE_TIME: float = 2.0
const MIN_GRIP_FATIGUE_TIME: float = 0.8
#for LOOSENED state
const MAX_HOLD_TIME: float = 3.0
const MIN_HOLD_TIME: float = 0.2
#how quickly velocity cancels on grip contact
const GRIP_VELOCITY_DAMPING: float = 8000.0
const SLIDE_GRAVITY_SCALE: float = 0.18
const FALL_GRAVITY_SCALE: float = 0.85

var state: GripState = GripState.NONE
var current_wall: WallData = null
var hold_timer: float = 0.0
var player: Player = null
var grip_fatigue_timer: float = 0.0

func _ready() -> void:
	player = get_parent() as Player
	if player == null:
		push_error("WallGripHandler must be a child of a player") 

#counts down _hold_timer when LOOSENED and enters SLIDING when it expires
func _physics_process(delta: float) ->void:
	if state == GripState.NONE:
		return
	if player.is_on_floor():
		release_grip()
		return
	if not player.is_on_wall():
		release_grip()
		return
	if state == GripState.GRIPPED:
		grip_fatigue_timer -= delta
		if grip_fatigue_timer <= 0.0:
			loosen_grip()
	if state == GripState.LOOSENED:
		hold_timer-=delta
		if hold_timer<=0.0:
			enter_sliding()

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
	#calculate how long the player stays still based on grip_power
	var t: float = inverse_lerp(IMMEDIATE_SLIDE_THRESHOLD, 100.0, surface_grip)
	t = clamp(t, 0.0, 1.0)
	grip_fatigue_timer = lerp(MIN_GRIP_FATIGUE_TIME, MAX_GRIP_FATIGUE_TIME, t)
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
	hold_timer = lerp(MIN_HOLD_TIME, MAX_HOLD_TIME, t)
	emit_signal("grip_state_changed", GripState.LOOSENED)

#Immediately calls _release_grip to clear grip on any wall jump
func release_on_jump() -> void:
	release_grip()

#Returns GRIP_VELOCITY_DAMPING if GRIPPED or LOOSENED, otherwise 0
#Called by Player._apply_grip_damping
func get_velocity_damping() ->float:
	if state == GripState.GRIPPED:
		return GRIP_VELOCITY_DAMPING
	return 0.0

#emits grip_state_changed
#Called by _physics_process when the LOOSENED hold timer runs out
func enter_sliding() -> void:
	state =GripState.SLIDING
	emit_signal("grip_state_changed", GripState.SLIDING)

#Resets state to NONE, clears current_wall and timer, emits grip_lost and grip_state_changed
#Called by _physics_process and release_on_jump
func release_grip() -> void:
	if state == GripState.NONE:
		return
	state = GripState.NONE
	current_wall = null
	hold_timer = 0.0
	emit_signal("grip_lost")
	emit_signal("grip_state_changed", GripState.NONE)

#returns the gravity scale for the current phase
#LOOSENED = gentle slide, SLIDING = fast fall anything else = no wall gravity
func get_gravity_scale() -> float:
	if state == GripState.LOOSENED:
		return SLIDE_GRAVITY_SCALE
	if state == GripState.SLIDING:
		return FALL_GRAVITY_SCALE
	return 0.0
	
# Called by Player.read_wall_tile every frame while gripped.
# Re-evaluates state whenever the tile's anchoring value changes.
func update_grip_power(new_power: float) -> void:
	if state == GripState.NONE or current_wall == null:
		return
	current_wall.grip_power = new_power
	# Drop straight to SLIDING if the new tile can't hold the player
	if new_power < IMMEDIATE_SLIDE_THRESHOLD:
		if state == GripState.GRIPPED or state == GripState.LOOSENED:
			enter_sliding()
