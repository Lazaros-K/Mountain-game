In order to make a map fragment please copy the scene tree structure and logic from map_fragment_template.tscn
Structure:
Root node should always be a TileMapManager
	decoration_layer	 -> Meant for decoration tiles
	hazarad_layer		 -> Meant for hazard tiles with no texture
	solid_layer			 -> Meant for tiles with texture and collision
	solid_mock_layer	 -> Meant for populating the scene with the solid tiles texture without the extra information and collisions
map objects and enemies are also available on world_map/tile_system/map_objects directory

Every layer should have a corrisponding tileset
