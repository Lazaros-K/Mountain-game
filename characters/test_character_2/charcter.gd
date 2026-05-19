extends CharacterBody2D

signal damage
signal heal
signal died

@onready var left_point: MapDetectionPoint = $LeftDetectionPoint
@onready var right_point: MapDetectionPoint = $RightDetectionPoint
@onready var base_point: CharacterMapPoint = $CharacterMapPoint
@onready var timer: Timer = $Timer

@export var speed: float = 160.0
@export var jump_velocity: float = -250.0
@export var fly: bool = false

@export var max_wall_jump_velocity: Vector2 = Vector2(400.0, -350.0)
@export var min_wall_jump_velocity: Vector2 = Vector2(180.0, -250.0)
@export var anchoring_threshold: float = 20.0
@export var max_slide_speed: float = 180.0    
@export var min_slide_speed: float = 30.0

@export var max_health: int = 3

var is_invincible: bool = false

var current_health: int
var current_friction: float = 100.0 
var current_wall_anchoring: float = 0.0 
var counter:int =0
var current_fragment_index: int = -1

func _ready() -> void:
	current_health = max_health

# whatever starts with 'c_' mean that it is called by the game controller
func c_setup_character(mg: MapGenerator, start_fragment: MapFragment) -> void :
	base_point.map_fragment = start_fragment
	base_point.connect("map_fragment_changed",mg._on_character_map_fragment_changed)

func _physics_process(delta: float) -> void :
	var direction: float = Input.get_axis("left", "right")
	if direction != 0:
		#flips the sprite for when we add sprites
		$AnimatedSprite2D.flip_h = direction < 0 as bool
		
	if not is_on_floor():
		current_friction = 100.0
		$AnimatedSprite2D.play("jump")
	else:
		if direction != 0:
			$AnimatedSprite2D.play("walk")
			counter=0
		else:
			if (counter<4):
				$AnimatedSprite2D.play("stop")
				if $AnimatedSprite2D.frame_changed:
					counter+=1
			else:
				$AnimatedSprite2D.play("default")
	
	
	
	
	if fly:
		movement_fly()
	else:
		movement_walk(delta)
	
	var slide_rate: float = current_friction * 10.0
	
	if direction:
		velocity.x = direction * speed
	else:
		if current_friction >= 100:
			velocity.x = move_toward(velocity.x, 0, speed * 15.0 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, slide_rate * delta)
	
	move_and_slide()
	

func get_on_floor_data() -> void :
	var tile_data: TerrainTileData = base_point.get_data()
	if not tile_data :
		current_friction = 100.0
		return
	current_friction = tile_data.friction
	print("floor friction: " ,tile_data.friction)

func get_on_wall_data() -> void :
	var tile_data: TerrainTileData
	$AnimatedSprite2D.play("wall")
	# Check where the sprite is looking
	var is_facing_left: bool = $AnimatedSprite2D.flip_h
	
	# Use the left point
	if is_facing_left:
		tile_data = left_point.get_data()
	else:
		# Use the right point
		tile_data = right_point.get_data()
		
	if not tile_data :
		current_wall_anchoring = 0.0
		return
		
	current_wall_anchoring = tile_data.wall_anchoring
	print("wall anchroring: " ,tile_data.wall_anchoring)

func movement_fly() -> void:
	
	var direction: float = Input.get_axis("up", "down")
	if direction:
		velocity.y = direction * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	if not is_on_floor():
		if is_on_wall():
			# this runs when character isn't on the floor and is on a wall
			get_on_wall_data()
		return
	
	# this runs when character is on the floor
	get_on_floor_data()
	

func movement_walk(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if is_on_wall():
			# this runs when character isn't on the floor and is on a wall
			get_on_wall_data()
			
			# wall sliding
			var grip_factor: float = clamp(current_wall_anchoring / 100.0, 0.0, 1.0)
			var current_slide_speed: float = lerp(max_slide_speed, min_slide_speed, grip_factor)
			
			if velocity.y > current_slide_speed:
				velocity.y = current_slide_speed
			
			# Wall Jump
			if Input.is_action_just_pressed("jump"):
				if current_wall_anchoring >= anchoring_threshold:
					# Successful jump
					var wall_normal: Vector2 = get_wall_normal()
					var current_jump_x: float = lerp(min_wall_jump_velocity.x, max_wall_jump_velocity.x, grip_factor)
					var current_jump_y: float = lerp(min_wall_jump_velocity.y, max_wall_jump_velocity.y, grip_factor)
					
					velocity.x = wall_normal.x * current_jump_x
					velocity.y = current_jump_y
				else:
					# Can't jump because of threshold
					pass
		return
	
	# this runs when character is on the floor
	get_on_floor_data()
	current_wall_anchoring = 0.0 # Resets on ground
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func take_damage(amount: int) -> void:
	#local damage taking
	for i:int in range(amount):
		if current_health > 0:
			current_health -= 1
			damage.emit()
			
	if current_health <= 0:
		die()

func heal_character(amount: int) -> void:
	#local healing
	for i:int in range(amount):
		if current_health < max_health:
			current_health += 1
			heal.emit() 

func die() -> void:
	print("Character died!")
	died.emit()

# Mock function made for testing
func receive_hit_payload(payload: HitPayload) -> void :
	if is_invincible:
		return
		
	payload.info();
	take_damage(payload.damage);
	
	if current_health <= 0:
		return
	
	#Knockback
	velocity.y = -300.0
	
	if velocity.x > 0:
		velocity.x = -200.0
	elif velocity.x < 0:
		velocity.x = 200.0
	
	start_invincibility(0.5)
	
func start_invincibility(duration: float) -> void:
	is_invincible = true
	# makes character slightly transparent for visuals
	modulate.a = 0.5
	await get_tree().create_timer(duration).timeout
	
	is_invincible = false
	modulate.a = 1.0 # transparency reset
