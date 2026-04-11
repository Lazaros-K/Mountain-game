extends Node

@export var rooms: Array[PackedScene]

# Chunk window values ( Can be used for settings )
@export var chunks_ahead: int = 2
@export var chunks_behind: int = 2

# Seed Values ( Can be used for settings )
@export var use_custom_seed: bool = false
@export var level_seed: int = 12345


var generated_chunk_memory: Dictionary = {} # All chunks generated over progression
var active_chunks: Dictionary = {} # Chunks active in scene

var next_spawn_position: Vector2 = Vector2.ZERO
var highest_generated_index: int = -1



func _ready() -> void:
	
	# Checks if we use custom seed
	if use_custom_seed:
		seed(level_seed)
	else:
		randomize()
	
	# First chunk creation and loading
	for i: int in range(chunks_ahead + 1):
		generate_chunk_data(i)
		
	update_chunk_window(0)

func generate_chunk_data(index: int) -> void:
	if generated_chunk_memory.has(index):
		return
		
	var room_to_spawn: PackedScene
	room_to_spawn = rooms.pick_random()
		
	# Temp nodes to read the markers
	var temp_room: TileMapManager = room_to_spawn.instantiate()
	var spawn_pos: Vector2 = next_spawn_position
	
	# Saves spawn position from entrance marker
	var entrance_marker: Marker2D = temp_room.entrance_marker
	if entrance_marker != null:
		spawn_pos -= entrance_marker.position
		
	# Saves exit position for the next time
	var exit_marker: Marker2D = temp_room.exit_marker
	if exit_marker != null:
		next_spawn_position = spawn_pos + exit_marker.position
		
	# Save data from above
	generated_chunk_memory[index] = {
		"scene": room_to_spawn,
		"position": spawn_pos
	}
	
	highest_generated_index = index
	temp_room.queue_free()
	
func update_chunk_window(current_player_index: int) -> void:
	var start_index: int = max(0, current_player_index - chunks_behind)
	var end_index: int = current_player_index + chunks_ahead
	
	# Generates chunks while we're behind
	while highest_generated_index < end_index:
		generate_chunk_data(highest_generated_index + 1) 
		
	# Load non active chunks
	for i: int in range(start_index, end_index + 1):
		if not active_chunks.has(i):
			load_chunk(i)
			
	# Unload far behind or ahead chunks
	for loaded_index:int in active_chunks.keys():
		if loaded_index < start_index or loaded_index > end_index:
			unload_chunk(loaded_index)
			

# "Imports" chunk from Dictionary index, gives it the correct position and index
# and adds it to the active chunks
func load_chunk(index: int) -> void:
	var data: Dictionary = generated_chunk_memory[index]
	var room_scene: PackedScene = data["scene"]
	var new_room: TileMapManager = room_scene.instantiate() as TileMapManager
	new_room.global_position = data["position"]
	new_room.fragment_index = index
	
	self.add_child(new_room)
	active_chunks[index] = new_room

# Finds the room that needs unloading the the active_chunks
# and deletes it from both the active dictionary and ram
func unload_chunk(index: int) -> void:
	if active_chunks.has(index):
		var room: TileMapManager = active_chunks[index]
		room.queue_free()
		active_chunks.erase(index)
