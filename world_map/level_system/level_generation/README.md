Brief Scripts Explanation: 

{MapGenerator.gd}

[initialize_pool()]: For every room in the rooms we have it instantiates it
by the amount of times we set, puts every duplicate far away, disables it,
makes it invisible and adds it to the room_pool dictionary.

[get_free_room()]: We input the room we want, searches for an available
duplicate and returns the according duplicate

[update_chunk_window()]: It looks at the player's current fragment index
αnd manages a "window" of active rooms (2 rooms ahead, 2 rooms behind)
deciding which rooms need to be loaded or unloaded. It also indexes new rooms


[activate_fragment_from_pool()]: Activates specific fragment from the pool


[generate_and_append_fragment()]: Checks if the room is in history, 
generates random sequence, activates the random fragment from the pool
and calculates the correct next position

[unload_chunk()]: When a room falls outside the window, it 
erases it from active_fragments and disables it and makes it invisible

{character.gd}

[check_for_fragment_change()]: 
It compares the chunk index the player is currently touching (new_index) 
against the chunk they were previously on (current_fragment_index).

If the numbers are different (meaning the player just crossed into a new room)
it updates its internal tracker and emits the map_fragment_changed signal.

These are checked on the functions [get_on_floor_data()] and [get_on_wall_data()]:
by adding this part: "check_for_fragment_change(current_map_fragment.fragment_index")

{TileMapManager.gd}

The function [setup_dynamic_mask()] was added for adding the Area2D 
by script which is responsible for identifying the map fragment

These:
@export var entrance_marker: Marker2D
@export var exit_marker: Marker2D

were also added so that level_manager.gd could access them directly from 
the TileMapManager instead of having to search by itsself for the markers
