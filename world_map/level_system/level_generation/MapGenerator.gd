class_name MapGenerator
extends Node

# For the first instantiated stuff
const POOL_STORAGE_POS: Vector2 = Vector2(-10000, -10000)

@export var rooms: Array[PackedScene] 

@export var chunks_ahead: int = 1
@export var chunks_behind: int = 1

@export var use_custom_seed: bool = false
@export var level_seed: int = 80085


# Object Pooling Variables
var pool_size_per_room: int = 3 
var room_pool: Dictionary[PackedScene, Array] = {}

var active_fragments: Dictionary[int, MapFragment] = {} 

## First array index has the scene, second has spawn position
var fragment_history: Dictionary[int, Array] = {}

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

## Instatiates all fragments, puts them far away and disables them
func initialize_pool() -> void:
	
	for room_scene: PackedScene in rooms:
		room_pool[room_scene] = []
		
		for i: int in range(pool_size_per_room):
			var new_fragment: MapFragment = room_scene.instantiate() as MapFragment
			
			# Disable and shi
			unload_fragment(new_fragment)
			add_child(new_fragment)
			room_pool[room_scene].append(new_fragment)

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
			@warning_ignore("unsafe_cast")
			activate_fragment_from_pool(i, fragment_history[i][0] as PackedScene)
	
	# Room unloading outside window
	for loaded_index: int in active_fragments.keys().duplicate():
		if loaded_index < start_index or loaded_index > end_index:
			unload_fragment(active_fragments[loaded_index])
			active_fragments.erase(loaded_index)

func generate_and_append_fragment(index: int) -> void:
	
	var fragment_scene: PackedScene = rooms.pick_random()
	
	# get fragment based on scene
	var fragment: MapFragment = get_free_room(fragment_scene)
	var fragment_pos: Vector2 = next_spawn_position - fragment.get_entrance_pos()
	next_spawn_position = fragment_pos + fragment.get_exit_pos()
	
	# set up fragment
	fragment.fragment_index = index
	fragment.position = fragment_pos
	fragment_history[index] = [fragment_scene,fragment_pos]
	
	# load fragment
	load_fragment(fragment)
	active_fragments[index] = fragment
	
	highest_generated_index = index

# Finds a free duplicate room from the pool
func get_free_room(room_scene: PackedScene) -> MapFragment:
	
	var instances: Array = room_pool[room_scene]
	for item: MapFragment in instances:
		if not item.visible:
			return item
	return null;

func activate_fragment_from_pool(index: int, scene: PackedScene) -> void:
	var fragment: MapFragment = get_free_room(scene)
	
	# add fragment to scene and set its position
	load_fragment(fragment)
	fragment.fragment_index = index
	fragment.position = fragment_history[index][1]
	
	# add fragment to active_fragments list
	active_fragments[index] = fragment

func unload_fragment(fragment: MapFragment) -> void:
	fragment.hide()
	fragment.position = POOL_STORAGE_POS
	fragment.process_mode = Node.PROCESS_MODE_DISABLED

func load_fragment(fragment: MapFragment) -> void :
	fragment.process_mode = Node.PROCESS_MODE_INHERIT
	fragment.show()

## Signal called function for updating the map
func _on_character_map_fragment_changed(new_index: int) -> void:
	update_chunk_window.call_deferred(new_index)
