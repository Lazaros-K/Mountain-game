class_name MapGenerator
extends Node

@export var rooms: Array[PackedScene] 

# Chunk window values ( Can be used for settings )
@export var chunks_ahead: int = 2
@export var chunks_behind: int = 2

# Seed Values ( Can be used for settings )
@export var use_custom_seed: bool = false
@export var level_seed: int = 80085


## All fragments generated over the progression
var generated_fragment_cache: Dictionary[int, PackedScene] = {}

## Map fragments active in scene
var active_fragments: Dictionary[int,MapFragment] = {} 

var next_spawn_position: Vector2 = Vector2.ZERO
var highest_generated_index: int = -1



func _ready() -> void:
	
	# Checks if we use custom seed
	if not use_custom_seed:
		level_seed = randi()
	seed(level_seed)
	print("Level seed is: ", level_seed)
	
	# First chunk creation and loading
	for i: int in range(chunks_ahead + 1):
		generate_and_append_fragment(i)
		
	update_chunk_window(0)

func update_chunk_window(current_player_index: int) -> void:
	var start_index: int = max(0, current_player_index - chunks_behind)
	var end_index: int = current_player_index + chunks_ahead
	
	# Generates new fragments
	while highest_generated_index < end_index:
		generate_and_append_fragment(highest_generated_index + 1) 
		
	# Load non active chunks
	for i: int in range(start_index, end_index + 1):
	# if not on active or generated we generate and append the fragment
		if not active_fragments.has(i):
			if generated_fragment_cache.has(i):
				load_chunk(i)
			else:
				generate_and_append_fragment(i)
			
	# Unload far behind or ahead chunks
	for loaded_index: int in active_fragments.keys():
		if loaded_index < start_index or loaded_index > end_index:
			unload_chunk(loaded_index)

# Gets a PackedScene from cache, we instantiate it,
# add it to the game and remove it from cache
func load_chunk(index: int) -> void:
	if not generated_fragment_cache.has(index):
		return
		
	# Obtain the saved scene from cache
	var packed_room: PackedScene = generated_fragment_cache[index]
	var loaded_room: MapFragment = packed_room.instantiate() as MapFragment
	
	# Manually save index so pack() doesn't reset it
	loaded_room.fragment_index = index
	
	# Add it to the game
	add_child(loaded_room)
	active_fragments[index] = loaded_room
	
	# Remove from cache since its active 
	generated_fragment_cache.erase(index)

# Gets an active room, creates an empty PackedScene to place it inside
func unload_chunk(index: int) -> void:
	if active_fragments.has(index):
		var room: MapFragment = active_fragments[index]
		
		# We create a new PackedScene and place inside the current rooms
		var packed_room: PackedScene = PackedScene.new()
		packed_room.pack(room)
		
		# Save it cache
		generated_fragment_cache[index] = packed_room
		
		# Delete from scene and active
		room.queue_free()
		active_fragments.erase(index)

# This should connected with the signal map_fragment_changed
# from CharacterMapPoint 
func _on_character_map_fragment_changed(new_index: int) -> void:
	update_chunk_window.call_deferred(new_index)
	
func generate_and_append_fragment(index: int) -> void:
	# If the index was already made (is cached) we dont 
	# make a new one and we load it
	if generated_fragment_cache.has(index) or active_fragments.has(index):
		return
		
	var room_to_spawn: PackedScene = rooms.pick_random()
		
	# Instantiate the room
	var new_room: MapFragment = room_to_spawn.instantiate()
	var spawn_pos: Vector2 = next_spawn_position
	
	# Calculates the ποσιτιον
	var entrance_marker: Marker2D = new_room.entrance_marker
	spawn_pos -= entrance_marker.position
	
	var exit_marker: Marker2D = new_room.exit_marker
	next_spawn_position = spawn_pos + exit_marker.position
	
	# Apply pos and index
	new_room.global_position = spawn_pos
	new_room.fragment_index = index
	
	# We directly add to scene
	add_child(new_room)
	active_fragments[index] = new_room
	
	highest_generated_index = max(highest_generated_index, index)
