class_name MapGenerator
extends Node2D

@export var fragments: Array[PackedScene]

# Chunk window values ( Can be used for settings )
@export var chunks_ahead: int = 2
@export var chunks_behind: int = 2

# Seed Values ( Can be used for settings )
@export var use_custom_seed: bool = false
@export var level_seed: int = 80085


## All fragments generated over the progression
var generated_fragment_cache: Dictionary[int,Dictionary] = {}
## Map fragments active in scene
var active_fragments: Dictionary[int,MapFragment] = {} 

var next_spawn_position: Vector2 = Vector2.ZERO
var highest_generated_index: int = -1



func _ready() -> void:
	
	if fragments.size() == 0 :
		printerr("Map Generator has no fragments")
		get_tree().quit(1)
	
	# Checks if we use custom seed
	if not use_custom_seed:
		level_seed = randi()
	seed(level_seed)
	print("Level seed is: ", level_seed)
	
	# First chunk creation and loading
	for i: int in range(chunks_ahead + 1):
		generate_chunk_data(i)
		
	update_chunk_window(0)

func generate_chunk_data(index: int) -> void:
	if generated_fragment_cache.has(index):
		return
		
	var room_to_spawn: PackedScene
	room_to_spawn = fragments.pick_random()
		
	# Temp nodes to read the markers
	var temp_room: MapFragment = room_to_spawn.instantiate()
	var spawn_pos: Vector2 = next_spawn_position
	
	# Modifies spawn position
	spawn_pos -= temp_room.get_entrance_pos()
	
	# Saves exit position for the next fragment spawn
	next_spawn_position = spawn_pos + temp_room.get_exit_pos()
	
	# Cache spawned fragmetn
	generated_fragment_cache[index] = {
		"scene": room_to_spawn,
		"position": spawn_pos
	}
	
	highest_generated_index = index
	temp_room.queue_free()

func update_chunk_window(current_player_index: int) -> void:
	var start_index: int = max(0, current_player_index - chunks_behind)
	var end_index: int = current_player_index + chunks_ahead
	
	# Generates new fragments
	while highest_generated_index < end_index:
		generate_chunk_data(highest_generated_index + 1) 
		
	# Load non active chunks
	for i: int in range(start_index, end_index + 1):
		if not active_fragments.has(i):
			load_chunk(i)
			
	# Unload far behind or ahead chunks
	for loaded_index: int in active_fragments.keys():
		if loaded_index < start_index or loaded_index > end_index:
			unload_chunk(loaded_index)
			

# Instantiates fragment from Dictionary based on the index, gives it the correct position
# and adds it to the active chunks
func load_chunk(index: int) -> void:
	var data: Dictionary = generated_fragment_cache[index]
	var room_scene: PackedScene = data["scene"]
	var new_room: MapFragment = room_scene.instantiate() as MapFragment
	new_room.global_position = data["position"]
	new_room.fragment_index = index
	
	self.add_child(new_room)
	active_fragments[index] = new_room

# Finds the room that needs unloading in the active_fragments,
# and deletes it from both the active dictionary and the scene
func unload_chunk(index: int) -> void:
	if active_fragments.has(index):
		var room: MapFragment = active_fragments[index]
		room.queue_free()
		active_fragments.erase(index)


func _on_character_map_fragment_changed(new_index: int) -> void:
	update_chunk_window(new_index)
