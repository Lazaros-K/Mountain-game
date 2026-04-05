class_name TileMapManager
extends Node2D
## Provides an interface for tile map communication

@export var tilemap_id: String
@export var solid_layer: TileMapLayer

func _ready() -> void:
	pass

## Returns the SolidTileData of the tile in actor_position
func get_tile_data(actor_position: Vector2) -> SolidTileData :
	
	var local_position: Vector2 = solid_layer.to_local(actor_position)
	var map_position: Vector2i = solid_layer.local_to_map(local_position)
	var tile_data: TileData = solid_layer.get_cell_tile_data(map_position)
	
	if not tile_data:
		return null
		
	return SolidTileData.new(tile_data)
	
