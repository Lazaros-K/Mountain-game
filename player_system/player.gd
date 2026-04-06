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
const BASE_JUMP_VELOCITY: float = 300.0
const JUMP_SPEED_SCALE: float = 0.6
const GRAVITY: float = 900.0

#player movement control in air
const AIR_CONTROL_FORCE: float = 120.0

#maximum speed the air control nudge can add in any direction.
#prevents air control from completely overriding the initial jump arc
const AIR_CONTROL_MAX_CONTRIBUTION: float = 80.0

var _on_floor: bool = false

#cmd is a filled playercommand describing what the player wants
func apply_command(cmd: PlayerCommand) ->void:
	print("apply_command: on_floor=", is_on_floor(), " vel=", velocity)
	_on_floor = is_on_floor()
	if _on_floor:
		_process_ground(cmd)
	else:
		_process_air(cmd)
	velocity.y+= GRAVITY * get_physics_process_delta_time()
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
	var dt: float = get_physics_process_delta_time()
	#apply a small horizontal nudge in the air control direction
	#clamp prevents the air-control contribution from exceeding its cap
	#so the initial jump arc stays dominant
	if cmd.air_horizontal !=0.0:
		var nudge: float = cmd.air_horizontal*AIR_CONTROL_FORCE*dt
		velocity.x= clamp(
			velocity.x + nudge,
			-MAX_GROUND_SPEED-AIR_CONTROL_MAX_CONTRIBUTION,
			MAX_GROUND_SPEED+AIR_CONTROL_MAX_CONTRIBUTION
		)
	
	#if cmd.air_vertical != 0.0:
		#var v_nudge: float = cmd.air_vertical*AIR_CONTROL_FORCE*dt
		#velocity.y+=v_nudge
func _ready() -> void:
	print("Player node READY")

func _physics_process(delta: float) -> void:
	print("Player _physics_process running")
