extends CharacterBody2D

@onready var grab_point: MapDetectionPoint = $MapDetectionPoint
@onready var base_point: CharacterMapPoint = $CharacterMapPoint

@export var speed: float = 220.0
@export var jump_velocity: float = -250.0
@export var fly: bool = false

var current_fragment_index: int = -1

# whatever starts with 'c_' mean that it is called by the game controller
func c_setup_character(mg: MapGenerator, start_fragment: MapFragment) -> void :
	base_point.map_fragment = start_fragment
	base_point.connect("map_fragment_changed",mg._on_character_map_fragment_changed)

func _physics_process(delta: float) -> void :
	
	if fly:
		movement_fly()
	else:
		movement_walk(delta)
	
	var direction: float = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	

func get_on_floor_data() -> void :
	var tile_data: TerrainTileData = base_point.get_data()
	if not tile_data :
		return
	print("floor friction: " ,tile_data.friction)

func get_on_wall_data() -> void :
	var tile_data: TerrainTileData = grab_point.get_data()
	if not tile_data :
		return
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
		return
	
	# this runs when character is on the floor
	get_on_floor_data()
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

# Mock function made for testing
func receive_hit_payload(payload: HitPayload) -> void :
	payload.info();
	
