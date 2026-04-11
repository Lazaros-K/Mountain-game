extends CharacterBody2D

signal map_fragment_changed(new_index: int)

@onready var grab_point: MapDetectionPoint = $grab_point
@onready var feet_point: MapDetectionPoint = $feet_point

# when more the one map fragmetns will be available, this should be updated every frame
@export var current_map_fragment: TileMapManager
@export var speed: float = 220.0
@export var jump_velocity: float = -250.0
@export var fly: bool = false

var current_fragment_index: int = -1

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
	current_map_fragment = feet_point.get_data()
	if current_map_fragment:
		check_for_fragment_change(current_map_fragment.fragment_index)
	var tile_data: SolidTileData = current_map_fragment.get_tile_data(feet_point.global_position)
	if not tile_data :
		return
	print("floor friction: " ,tile_data.friction)

func get_on_wall_data() -> void :
	current_map_fragment = grab_point.get_data()
	if current_map_fragment:
		check_for_fragment_change(current_map_fragment.fragment_index)
	var tile_data: SolidTileData = current_map_fragment.get_tile_data(feet_point.global_position)
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

func check_for_fragment_change(new_index: int) -> void:
	if new_index != current_fragment_index:
		current_fragment_index = new_index
		map_fragment_changed.emit(current_fragment_index)

# Mock function made for testing
func receive_hit_payload(payload: HitPayload) -> void :
	payload.info();
	
