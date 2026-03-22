extends CharacterBody2D


@export var speed: float = 220.0
@export var jump_velocity: float = -250.0
@export var fly: bool = false

func _physics_process(delta: float) -> void :
	
	var tile_speed: float = get_tile_speed()
	var tile_damage: int = get_tile_damage()
	
	if fly:
		movement_fly()
	else:
		movement_walk(delta)
	
	var direction: float = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		if tile_speed != 0:
			velocity.x = move_toward(velocity.x, 0, tile_speed)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	if tile_damage != 0:
		$health.damage(tile_damage)
		velocity.y = jump_velocity

func movement_fly() -> void:
	
	var direction: float = Input.get_axis("up", "down")
	if direction:
		velocity.y = direction * speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	

func movement_walk(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		

#Finds the tile map, and checks for the tile below the player
#Each tile has a data layer (a set value for damage and friction for now
#they are values set on the collision_layer object) we identify the tile and collect
#its data value (damage and friction) 

func get_tile_speed() -> float:
	var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap")
	
	if not tilemap:
		return 220.0
	
	var foot_offset := Vector2(0, 14)
	var cell := tilemap.local_to_map(position + foot_offset)
	var data: TileData = tilemap.get_cell_tile_data(cell)
	
	if data:
		var tile_friction: float = data.get_custom_data("tile_friction")
		if tile_friction > 0:
			return tile_friction
	return 0

#Works the same way as the function above

func get_tile_damage() -> float:
	var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap")
	
	if not tilemap:
		return 0
	
	var foot_offset := Vector2(0, 14)
	var cell := tilemap.local_to_map(position + foot_offset)
	var data: TileData = tilemap.get_cell_tile_data(cell)
	
	if data:
		var tile_damage: int = data.get_custom_data("tile_damage")
		if tile_damage > 0:
			return tile_damage
	return 0
