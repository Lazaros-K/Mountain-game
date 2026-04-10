#character class owns the physics body 
#and all movement rules it only receives a player command and acts accordingly
#extends CharacterBody2D so Godot handles collision detection and
#move_and_slide() for us
class_name Player
extends CharacterBody2D

const GROUND_ACCELERATION: float = 800.0
const MAX_GROUND_SPEED: float = 300.0

#friction applied when no directional input is given on the ground
#higher = stops faster
const GROUND_FRICTION: float = 1200.0
const BASE_JUMP_VELOCITY: float = 200.0
const JUMP_SPEED_SCALE: float = 0.3
const GRAVITY: float = 900.0
const REGRIP_COOLDOWN: float = 0.25
const WALL_JUMP_SIDE_UP_VELOCITY: float = 200.0
const WALL_JUMP_UP_VELOCITY: float = 340.0
const WALL_JUMP_DIAG_X: float = 280.0
const WALL_JUMP_DIAG_Y: float = 300.0
#player movement control in air
const AIR_CONTROL_FORCE: float = 120.0
#maximum speed the air control nudge can add in any direction.
#prevents air control from completely overriding the initial jump arc
const AIR_CONTROL_MAX_CONTRIBUTION: float = 80.0
const WALL_JUMP_SIDE_VELOCITY: float = 280.0

var _on_floor: bool = false
var _wall_side: int = 0
var _regrip_timer: float = 0.0

@onready var grip_handler: WallGripHandler = $WallGripHandler
#cmd is a filled playercommand describing what the player wants
func _ready() -> void:
	grip_handler.gripped.connect(_on_gripped)
	grip_handler.grip_lost.connect(_on_grip_lost)
	grip_handler.grip_state_changed.connect(_on_grip_state_changed)

func _apply_grip_damping() -> void:
	var dt := get_physics_process_delta_time()
	var damping := grip_handler.get_velocity_damping()
	velocity.x = move_toward(velocity.x, 0.0, damping * dt)
	velocity.y = move_toward(velocity.y, 0.0, damping * dt)

func apply_command(cmd: PlayerCommand) ->void:
	var dt := get_physics_process_delta_time()
	_on_floor = is_on_floor()
	_update_wall_side()
	if _regrip_timer > 0.0:
		_regrip_timer -= dt

	var grip_state:= grip_handler.state
	
	match grip_state:
		WallGripHandler.GripState.GRIPPED:
			_apply_grip_damping()
			if cmd.wall_jump_left:
				_wall_jump_diagonal(-1)
			elif cmd.wall_jump_right:
				_wall_jump_diagonal(1)
			elif cmd.jump_pressed:
				_wall_jump_up()
			elif cmd.press_away_from_wall:
				grip_handler.loosen_grip()
			move_and_slide()
			return
 
		WallGripHandler.GripState.LOOSENED:
			_apply_grip_damping()
			if cmd.wall_jump_left:
				_wall_jump_diagonal(-1)
			elif cmd.wall_jump_right:
				_wall_jump_diagonal(1)
			elif cmd.jump_pressed:
				_wall_jump_up()
			velocity.y += GRAVITY * 0.15 * dt
			move_and_slide()
			return
 
		WallGripHandler.GripState.SLIDING:
			velocity.y += GRAVITY * grip_handler.get_gravity_scale() * dt
			move_and_slide()
			return
			
	if _on_floor:
		_process_ground(cmd)
	else:
		_process_air(cmd)
	velocity.y+= GRAVITY * get_physics_process_delta_time()
	if not _on_floor and is_on_wall() and _regrip_timer <= 0.0:
		var surface_grip: float = _get_wall_surface_grip()
		grip_handler.try_grip(_wall_side, surface_grip)
	move_and_slide()

func _process_ground(cmd: PlayerCommand) -> void:
	var dt: float = get_physics_process_delta_time()
	
	if cmd.move_direction !=0.0:
		#accelerate toward the desired direction without overshooting max ground speed
		velocity.x = move_toward(
			velocity.x,
			cmd.move_direction*MAX_GROUND_SPEED,
			GROUND_ACCELERATION*dt
			)
	else:
		velocity.x= move_toward(velocity.x,0.0,GROUND_FRICTION*dt)
	
	if cmd.jump_pressed:
		_start_jump()

func _start_jump() -> void:
	var speed_bonus: float = abs(velocity.x)*JUMP_SPEED_SCALE
	velocity.y=-(BASE_JUMP_VELOCITY+speed_bonus)

func _process_air(cmd :PlayerCommand)->void:
	var dt := get_physics_process_delta_time()
	if cmd.air_horizontal != 0.0:
		var nudge := cmd.air_horizontal*AIR_CONTROL_FORCE*dt
		velocity.x = clamp(velocity.x+nudge,-MAX_GROUND_SPEED-AIR_CONTROL_MAX_CONTRIBUTION,MAX_GROUND_SPEED+AIR_CONTROL_MAX_CONTRIBUTION)

func _physics_process(delta: float) -> void:
	pass

func _update_wall_side() -> void:
	if is_on_wall(): 
		var normal := get_wall_normal()
		_wall_side = -sign(normal.x) as int
	else:
		_wall_side = 0

func _get_wall_surface_grip() -> float:
	return 100.0

func _wall_jump_up() -> void:
	velocity.x = 0.0
	velocity.y = -WALL_JUMP_UP_VELOCITY
	grip_handler.release_on_jump()
	_regrip_timer = REGRIP_COOLDOWN 

func _wall_jump_side() -> void:
	velocity.x = -grip_handler.current_wall.wall_side * WALL_JUMP_SIDE_VELOCITY
	velocity.y = -WALL_JUMP_SIDE_UP_VELOCITY
	grip_handler.release_on_jump()
	_regrip_timer = REGRIP_COOLDOWN

func _on_gripped(data: WallData) -> void:
	velocity = Vector2.ZERO

# Q (direction = -1) or E (direction = +1): diagonal jump ignoring wall side.
func _wall_jump_diagonal(direction: int) -> void:
	velocity.x = direction * WALL_JUMP_DIAG_X
	velocity.y = -WALL_JUMP_DIAG_Y
	grip_handler.release_on_jump()
	_regrip_timer = REGRIP_COOLDOWN

func _on_grip_lost() -> void:
	pass

func _on_grip_state_changed(new_state: WallGripHandler.GripState) -> void:
	pass
