Brief Scripts Explanation: 

{level_manager.md}

[generate_and_append_fragment()]: It picks a random room to spawn, 
calculates exactly where it goes, and adds it directly to the active 
scene. It no longer destroys temporary nodes as new rooms 
are immediately appended to the level.

[update_chunk_window()]: It looks at the player's current fragment index
αnd manages a "window" of active rooms (2 rooms ahead, 2 rooms behind)
deciding which rooms need to be generated, loaded, or unloaded.

[load_chunk() / unload_chunk()]: When a room falls outside the window,
unload_chunk() uses pack() to save its current state into the cache
before removing it from the scene to save RAM. When the player 
returns, load_chunk() restores that exact room from the 
cache and reapplies its index

Because chunks are packed and saved in the cache, the game doesn't 
just remember what room was there, but its exact state if the player 
decides to turn back. A very simple seed system is also 
implemented at the start.

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
