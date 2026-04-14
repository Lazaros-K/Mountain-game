class_name TerrainTileData
## Responsible for formating and storing a tile's TileData

var friction: int
var wall_anchoring: int

func _init(tile_data: TileData) -> void :
	friction = 100 - tile_data.get_custom_data("floor_slipperiness")
	wall_anchoring = tile_data.get_custom_data("wall_anchoring")
