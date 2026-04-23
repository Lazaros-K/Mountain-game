class_name MapGenerator
extends Node

# For the first instantiated stuff
const POOL_STORAGE_POS: Vector2 = Vector2(-10000, -10000)

@export var rooms: Array[PackedScene] 

@export var chunks_ahead: int = 2
@export var chunks_behind: int = 2

@export var use_custom_seed: bool = false
@export var level_seed: int = 80085


# Object Pooling Variables
@export var pool_size_per_room: int = 3 
var room_pool: Dictionary[PackedScene, Array] = {}

var active_fragments: Dictionary[int, MapFragment] = {} 
var fragment_history: Dictionary[int, PackedScene] = {}
var fragment_positions: Dictionary[int, Vector2] = {}

var next_spawn_position: Vector2 = Vector2.ZERO
var highest_generated_index: int = -1

func _ready() -> void:
	if rooms.is_empty():
		push_error("Map didn't generate. Place fragments first on MapGenerator")
		return
	
	if not use_custom_seed:
		level_seed = randi()
	seed(level_seed)
	
	# This part causes the lag when starting the game
	initialize_pool()
	
	for i: int in range(chunks_ahead + 1):
		generate_and_append_fragment(i)
		
	update_chunk_window(0)

# Instatiates all fragments, puts them far away and disables them
func initialize_pool() -> void:
	
	for room_scene: PackedScene in rooms:
		room_pool[room_scene] = []
		
		for i: int in range(pool_size_per_room):
			var new_room: MapFragment = room_scene.instantiate() as MapFragment
			
			# Disabling for performance
			new_room.global_position = POOL_STORAGE_POS
			new_room.visible = false
			new_room.process_mode = Node.PROCESS_MODE_DISABLED
			
			add_child(new_room) 
			room_pool[room_scene].append(new_room)

# Finds a free duplicate room from the pool
func get_free_room(room_scene: PackedScene) -> MapFragment:
	
	var instances: Array = room_pool[room_scene]
	for item: MapFragment in instances:
		var room: MapFragment = item as MapFragment
		
		if not room.visible:
			return room
	return null;

func update_chunk_window(current_player_index: int) -> void:
	var start_index: int = max(0, current_player_index - chunks_behind)
	var end_index: int = current_player_index + chunks_ahead
	
	# Creates new indexed room if moving forward
	while highest_generated_index < end_index:
		var next_idx: int = highest_generated_index + 1
		generate_and_append_fragment(next_idx)

	# Room loading inside window
	for i: int in range(start_index, end_index + 1):
		if not active_fragments.has(i):
			if fragment_history.has(i):
				activate_fragment_from_pool(i, fragment_history[i])
			
	# Room unloading outside window
	for loaded_index: int in active_fragments.keys().duplicate():
		if loaded_index < start_index or loaded_index > end_index:
			unload_chunk(loaded_index)


func activate_fragment_from_pool(index: int, scene: PackedScene) -> void:
	var room: MapFragment = get_free_room(scene)
	
	room.fragment_index = index
	room.visible = true
	# Basically enables the room
	room.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Checks if the pos was already calculated and applies it if so
	if fragment_positions.has(index):
		room.global_position = fragment_positions[index]

	active_fragments[index] = room

func generate_and_append_fragment(index: int) -> void:
	if fragment_history.has(index):
		return
		
	var room_scene: PackedScene = rooms.pick_random()
	fragment_history[index] = room_scene
	
	# Runs for new fragments
	activate_fragment_from_pool(index, room_scene)
	
	# Calculate next spawn pos
	var new_room: MapFragment = active_fragments[index]
	var spawn_pos: Vector2 = next_spawn_position
	spawn_pos -= new_room.entrance_marker.position
	new_room.global_position = spawn_pos
	next_spawn_position = spawn_pos + new_room.exit_marker.position
	
	# Save that pos
	fragment_positions[index] = spawn_pos
	
	highest_generated_index = max(highest_generated_index, index)

func unload_chunk(index: int) -> void:
	if active_fragments.has(index):
		var room: MapFragment = active_fragments[index]
		
		room.visible = false
		room.process_mode = Node.PROCESS_MODE_DISABLED
		
		active_fragments.erase(index)
		
# This should connected with the signal map_fragment_changed
# from CharacterMapPoint 
func _on_character_map_fragment_changed(new_index: int) -> void:
	update_chunk_window.call_deferred(new_index)
