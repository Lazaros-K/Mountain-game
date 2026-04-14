@abstract
class_name SpecialTileFactory
## Base class for Special tiles factories
## Every variation created is supposed to be cached

static var spike_tile_cache: Dictionary[String,PackedScene]

@abstract
## Returns an instance of the tile Specified
func create_special_tile(special_id: int, operational_tilemap: TileMapLayer, pos: Vector2i) -> Node2D

## Flashes the cache clean
func flash_cache() -> void :
	spike_tile_cache.clear()
