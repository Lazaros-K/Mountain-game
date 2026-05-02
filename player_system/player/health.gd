extends Node2D
class_name PlayerHealth

# Emitted whenever the heart count changes
signal hearts_changed(new_hearts: int)

# Emitted when hearts hit zero, before respawning.
signal died

@export var invincibility_duration: float = 0.5
#void kill
@export var void_y_threshold: float = 800.0

# position the player teleports to on respawn for testing and checkpoints if we have
@export var respawn_position: Vector2 = Vector2.ZERO

const MAX_HEARTS: int = 3

# Current hearts
var hearts: int = MAX_HEARTS

var is_invincible: bool = false

# blocks new damage during teleport.
var _is_respawning: bool = false

# Downward velocity (px/s) that must be exceeded on landing for fall damage to apply
const FALL_DAMAGE_VELOCITY_THRESHOLD: float = 1000.0

# Fall-speed to heart-damage table. Each row: [min_speed, max_speed, hearts_lost].
# Rows are checked top-to-bottom; the first matching range wins.
const FALL_DAMAGE_TABLE: Array = [
	[1000.0, 1400.0, 1],   # hard fall   → -1 heart
	[1400.0, INF,    2],   # lethal fall → -2 hearts
]

# Downward velocity recorded at the end of the previous physics frame.
# Compared against FALL_DAMAGE_VELOCITY_THRESHOLD on the landing frame.
var _prev_velocity_y: float = 0.0

# Cached reference to the parent Player node; resolved in _ready().
var _player: Player = null

func _ready() -> void:
	# Health must be a direct child of Player.
	_player = get_parent() as Player
	if _player == null:
		push_error("Health must be a child of a Player node.")
		return

	# Notify any connected HUD of the starting heart count.
	hearts_changed.emit(hearts)
	print("[Health] ready — hearts: ", hearts,
		  " | respawn pos: ", respawn_position)

func _physics_process(_delta: float) -> void:
	if _player == null or _is_respawning:
		return

	_check_void()
	_check_fall_landing()

	# Cache velocity for the next frame's landing-impact check.
	_prev_velocity_y = _player.velocity.y

# Remove one or more hearts from any source.
# Called by Player.receive_hit_payload for spikes and internally for fall damage
func damage(amount: int, source_label: String = "unknown") -> void:
	if is_invincible or _is_respawning:
		return

	hearts = max(0, hearts - amount)
	hearts_changed.emit(hearts)
	print("Damage hit: ", amount, " source: ", source_label,
		  " Hearts remaining: ", hearts)

	if hearts <= 0:
		die()
	else:
		start_invincibility()

func start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

# Called when hearts reach zero
# Resets to full hearts then respawns 
func die() -> void:
	died.emit()
	print("[Health] Player died — respawning with full hearts")
	hearts = MAX_HEARTS
	hearts_changed.emit(hearts)
	respawn()

# Update the respawn origin from Player._ready() or a checkpoint node
func set_respawn_position(pos: Vector2) -> void:
	respawn_position = pos
	print("[Health] Respawn position updated: ", respawn_position)

# Teleport the player back to respawn_position and clear all momentum
# Called after death, after a spike hit  Player.receive_hit_payload
# and after falling into the void
func respawn() -> void:
	if _is_respawning:
		return
	_is_respawning = true
	print("[Health] Respawning at: ", respawn_position)

	# Zero velocity so the player doesn't carry momentum into the spawn point
	_player.velocity = Vector2.ZERO
	_player.global_position = respawn_position
	_prev_velocity_y = 0.0

	# Wait one physics frame so Godot re-evaluates collisions at the new position
	await get_tree().physics_frame
	_is_respawning = false

# Checked every physics frame respawns the player when they fall below void_y_threshold just teleport back.
func _check_void() -> void:
	if _player.global_position.y > void_y_threshold:
		print("[Health] Fell into void at y=", _player.global_position.y)
		respawn()

# Checked every physics frame applies fall damage on the exact frame the
# player lands, based on the downward speed from the previous frame
func _check_fall_landing() -> void:
	# Only trigger on the first frame the player is on the floor
	if not _player.is_on_floor():
		return

	# _prev_velocity_y is positive when the player was moving downward
	var impact_speed: float = _prev_velocity_y
	if impact_speed < FALL_DAMAGE_VELOCITY_THRESHOLD:
		return  

	var hearts_lost: int = _get_fall_damage(impact_speed)
	if hearts_lost > 0:
		print("[Health] Fall damage | impact speed: ", impact_speed,
			  " px/s | hearts lost: ", hearts_lost)
		damage(hearts_lost, "fall")

# Walks FALL_DAMAGE_TABLE and returns hearts lost for the given fall speed.
func _get_fall_damage(speed: float) -> int:
	for entry in FALL_DAMAGE_TABLE:
		var min_speed: float = entry[0]
		var max_speed: float = entry[1]
		var hearts_lost: int = entry[2]
		if speed >= min_speed and speed < max_speed:
			return hearts_lost
	return 0
