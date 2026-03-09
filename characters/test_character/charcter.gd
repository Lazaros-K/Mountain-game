extends CharacterBody2D


@export var speed: float = 220.0
@export var jump_velocity: float = -250.0
@export var fly: bool = false

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
