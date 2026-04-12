Brief Scripts Explanation: 

{level_manager.md}
	
[generate_chunk_data()]: It pre-calculates what rooms to spawn and 
exactly where they go. It saves this data in a dictionary (memory) 
and destroys the temporary nodes so they don't consume RAM

[update_chunk_window()]: It looks at the player's current index and creates 
a "window" of active rooms (2 rooms ahead, 2 rooms behind)

[load_chunk()/unload_chunk()]: It instantiates (builds) the rooms 
that are inside the window. If a room falls outside the window, 
it gets destroyed to save memory.

Generated chunks are saved in the dictionary, the game will always 
remember exactly what room was there if the player decides to turn back.
A very simple seed system is also implemented at the start

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
