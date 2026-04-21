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

var on_floor: bool = false
var wall_side: int = 0
var regrip_timer: float = 0.0

var tile_friction_scale: float = 1.0

@onready var grip_handler: WallGripHandler = $WallGripHandler

#signal floor_tile_changed(tile_data: SolidTileData)
signal floor_tile_changed(tile_data: SolidTileData)
signal wall_tile_changed(wall_data: SolidTileData)

@export var current_map_fragment: TileMapManager
@onready var grab_point_left: Marker2D = $grab_point_left
@onready var grab_point_right: Marker2D = $grab_point_right
@onready var feet_point: Marker2D = $feet_point

#cmd is a filled playercommand describing what the player wants
func _ready() -> void:
	grip_handler.gripped.connect(on_gripped)
	print("map fragment: ", current_map_fragment)
	print("feet_point: ", feet_point)
	print("Left Grab Point: ", grab_point_left)
	print("Right Grab Point: ", grab_point_right)

#kills momentum on wall contact
#Called inside apply_command for gripped loosened states
func apply_grip_damping() -> void:
	var dt :float= get_physics_process_delta_time()
	var damping :float= grip_handler.get_velocity_damping()
	velocity.x = move_toward(velocity.x, 0.0, damping * dt)
	velocity.y = move_toward(velocity.y, 0.0, damping * dt)

# called by playercontrollee._physics_proccess
#Main entry point each frame updates floor/wall state ticks the regrip timer then 
#dispatches to the correct movement branch based on gripstatee
func apply_command(cmd: PlayerCommand) ->void:
	var dt :float= get_physics_process_delta_time()
	on_floor = is_on_floor()
	update_wall_side()
		
	if regrip_timer > 0.0:
		regrip_timer -= dt

	var grip_state:WallGripHandler.GripState= grip_handler.state
	
	match grip_state:
		WallGripHandler.GripState.GRIPPED:
			read_wall_tile()
			apply_grip_damping()
			if cmd.wall_jump_left:
				wall_jump_diagonal(-1)
			elif cmd.wall_jump_right:
				wall_jump_diagonal(1)
			elif cmd.jump_pressed:
				wall_jump_up()
			elif cmd.press_away_from_wall:
				grip_handler.loosen_grip()
			move_and_slide()
			return
		WallGripHandler.GripState.LOOSENED:
			#if cmd.wall_jump_left:
			#	wall_jump_diagonal(-1)
			#elif cmd.wall_jump_right:
			#	wall_jump_diagonal(1)
			#elif cmd.jump_pressed:
			#	wall_jump_up()
			velocity.y += GRAVITY * grip_handler.get_gravity_scale() * dt
			move_and_slide()
			return
		WallGripHandler.GripState.SLIDING:
			velocity.y += GRAVITY * grip_handler.get_gravity_scale() * dt
			move_and_slide()
			return
			
	if on_floor:
		read_floor_tile()
		process_ground(cmd)
	else:
		process_air(cmd)
	
	
	velocity.y+= GRAVITY * get_physics_process_delta_time()
	
	if not on_floor and is_on_wall() and regrip_timer <= 0.0:
		var surface_grip: float = get_wall_surface_grip()
		grip_handler.try_grip(wall_side, surface_grip)
	move_and_slide()

#Accelerates or friction-brakes on the X axis
#Called by apply_command when _on_floor is true
func process_ground(cmd: PlayerCommand) -> void:
	var dt: float = get_physics_process_delta_time()
	
	if cmd.move_direction !=0.0:
		#accelerate toward the desired direction without overshooting max ground speed
		velocity.x = move_toward(
			velocity.x,
			cmd.move_direction*MAX_GROUND_SPEED,
			GROUND_ACCELERATION*dt
			)
	else:
		velocity.x = move_toward(velocity.x, 0.0, GROUND_FRICTION * tile_friction_scale * dt)
	
	if cmd.jump_pressed:
		start_jump()

#Sets upward velocity, with a small bonus based on current horizontal speed
#Called by _process_ground
func start_jump() -> void:
	var speed_bonus: float = abs(velocity.x)*JUMP_SPEED_SCALE
	velocity.y=-(BASE_JUMP_VELOCITY+speed_bonus)

#Applies a small horizontal nudge (air control) clamped so it can't fully override the jump arc
#Called by apply_command when airborne and not wall-gripping
func process_air(cmd :PlayerCommand)->void:
	var dt :float= get_physics_process_delta_time()
	if cmd.air_horizontal != 0.0:
		var nudge :float= cmd.air_horizontal*AIR_CONTROL_FORCE*dt
		velocity.x = clamp(velocity.x+nudge,-MAX_GROUND_SPEED-AIR_CONTROL_MAX_CONTRIBUTION,MAX_GROUND_SPEED+AIR_CONTROL_MAX_CONTRIBUTION)

#Called every frame at apply_command
func update_wall_side() -> void:
	if is_on_wall(): 
		var normal :Vector2= get_wall_normal()
		wall_side = int(signf(-normal.x))
	else:
		wall_side = 0

#Called by apply_command 
func get_wall_surface_grip() -> float:
	return 100.0

#Called from apply_command
#Zeroes X velocity, launches straight up at WALL_JUMP_UP_VELOCITY, releases grip, starts regrip cooldown
func wall_jump_up() -> void:
	velocity.x = 0.0
	velocity.y = -WALL_JUMP_UP_VELOCITY
	grip_handler.release_on_jump()
	regrip_timer = REGRIP_COOLDOWN 

#Kicks sideways away from the wall and slightly up; releases grip, starts cooldown
func wall_jump_side() -> void:
	velocity.x = -grip_handler.current_wall.wall_side * WALL_JUMP_SIDE_VELOCITY
	velocity.y = -WALL_JUMP_SIDE_UP_VELOCITY
	grip_handler.release_on_jump()
	regrip_timer = REGRIP_COOLDOWN

#Zeroes velocity the moment a grip is registered
#Connected to WallGripHandler.gripped signal in _ready
func on_gripped(_data: WallData) -> void:
	velocity = Vector2.ZERO

#Called from apply_command
# Q (direction = -1) or E (direction = +1): diagonal jump ignoring wall side.
func wall_jump_diagonal(direction: int) -> void:
	velocity.x = direction * WALL_JUMP_DIAG_X
	velocity.y = -WALL_JUMP_DIAG_Y
	grip_handler.release_on_jump()
	regrip_timer = REGRIP_COOLDOWN

#Called by apply_command when on the floor
func read_floor_tile() -> void:
	if not current_map_fragment:
		return
	
	var tile_data: SolidTileData = current_map_fragment.get_tile_data(feet_point.global_position)
	
	if not tile_data:
		return
	tile_friction_scale = tile_data.friction / 100.0
	print("floor friction scale: ", tile_friction_scale)
	floor_tile_changed.emit(tile_data)

#Called by apply_command when GRIPPED
func read_wall_tile() -> void:
	if not current_map_fragment:
		print("read_wall_tile: no map fragment assigned")
		return
	var active_point: Marker2D = grab_point_left if wall_side == -1 else grab_point_right
	var tile_data: SolidTileData = current_map_fragment.get_tile_data(active_point.global_position)
	if not tile_data:
		print("read_wall_tile: no tile data at ", active_point.global_position)
		return
	print("wall anchoring: ", tile_data.wall_anchoring)
	wall_tile_changed.emit(tile_data)

func receive_hit_payload(payload: HitPayload) -> void:
	print("damage received: ", payload.damage, " from: ", payload.id)
