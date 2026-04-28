class_name SpikeFactory
extends SpecialTileFactory
## Factory to create spike instances

func _init() -> void :
	var spike_scene_uid: String = "uid://hyofwk3u5b44"
	if not spike_tile_cache.has("spike") :
		spike_tile_cache.set("spike", load(spike_scene_uid))

## Returns an instance of spikes special tile
func create_special_tile(special_id: int, operational_tilemap: TileMapLayer, pos: Vector2i) -> Node2D :
	
	# Based on were the spike is facing, edit position to find what they are based on
	if special_id == ResourceTiles.SPECIAL.SPIKE_DOWN :
		pos.y -= 1
	elif special_id == ResourceTiles.SPECIAL.SPIKE_RIGHT :
		pos.x -= 1
	elif special_id == ResourceTiles.SPECIAL.SPIKE_LEFT :
		pos.x += 1
	else :
		pos.y += 1
	
	# get the terrain_id of the tile the spikes are based on
	var cell_data: TileData = operational_tilemap.get_cell_tile_data(pos)
	var terrain_id: int = -1
	if cell_data :
		terrain_id = ResourceTiles.TERRAIN_MAP.get(cell_data.get_custom_data("tile_id"))
	
	var key: String = str(terrain_id) + "_" + str(special_id)
	
	# Search for cached tile
	if spike_tile_cache.has(key) :
		return spike_tile_cache[key].instantiate()
	
	# if the spike type isn't cached, create it
	var spike: Sprite2D = spike_tile_cache["spike"].instantiate()
	
	if terrain_id == ResourceTiles.TERRAIN.SNOW or terrain_id == ResourceTiles.TERRAIN.ICE :
		spike.texture = load("uid://dg6r1pgek32xm")
	elif terrain_id == ResourceTiles.TERRAIN.SLATE :
		spike.texture = load("uid://n7rm4wuas7tb")
	
	if special_id == ResourceTiles.SPECIAL.SPIKE_DOWN :
		spike.rotation_degrees = 180
	elif special_id == ResourceTiles.SPECIAL.SPIKE_RIGHT :
		spike.rotation_degrees = 90
	elif special_id == ResourceTiles.SPECIAL.SPIKE_LEFT :
		spike.rotation_degrees = -90
	
	# create a packed scene, cache and return
	var packed_tile: PackedScene = PackedScene.new()
	var error: Error = packed_tile.pack(spike)
	if error != OK:
		printerr("Failed to pack spike tile " + key)
	spike_tile_cache.set(key,packed_tile)
	
	return spike
