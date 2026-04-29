Loading Screen extention to include map generation

When creating the main level, a MapGenerator will run its script for the first
time and try to instantiate all of the pool in one frame resulting to a freeze

The core idea is to fixing it is instantiating each fragment in a frame by
using [await get_tree().process_frame]. After loading the resources as we did,
we instantiate the main scene, find the MapGenerator and connect its signals. 
[total_rooms] Sends a signal of the total rooms inside the pool
[chunk_loaded] Sends a signal everytime a new room is instantiated
[map_fully_generated] A final signal that emits after we update_chunk_window(0)

Using these signals we can track the loading process, show it to the user and
prevent exposure to freezing after loading

Also changed this on restart to prevent freezing there too:
[get_tree().change_scene_to_file(scene_uid.LOADING_SCREEN)]
