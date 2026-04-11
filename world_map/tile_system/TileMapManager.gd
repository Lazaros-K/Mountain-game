class_name TileMapManager
extends Node2D
## Provides an interface for tile map communication

@export var tilemap_id: String
@export var solid_layer: TileMapLayer
@export var entrance_marker: Marker2D
@export var exit_marker: Marker2D

var fragment_index: int = 0

func _ready() -> void:
	if solid_layer:
		setup_dynamic_mask() ## Creates the Area2D At the start
	
## Function for creating the detection Area2D's by script
func setup_dynamic_mask() -> void:
	## Tilemap limits
	var used_rect: Rect2i = solid_layer.get_used_rect()
	var tile_size: Vector2i = solid_layer.tile_set.tile_size
	
	## Converts to pixels
	var width: int = used_rect.size.x * tile_size.x
	var height: int = used_rect.size.y * tile_size.y
	
	## Area2D Creation
	var area: Area2D = Area2D.new()
	area.name = "fragment_area"
	area.collision_layer = 0
	area.collision_mask = 0
	area.set_collision_layer_value(8, true)
	
	## CollisionShape2D Creation
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(width, height)
	collision_shape.shape = rect_shape
	
	var offset: Vector2 = Vector2(used_rect.position) * Vector2(tile_size)
	collision_shape.position = offset + (rect_shape.size / 2.0)
	
	area.add_child(collision_shape)
	add_child(area)

## Returns the SolidTileData of the tile in actor_position
func get_tile_data(actor_position: Vector2) -> SolidTileData :
	
	var local_position: Vector2 = solid_layer.to_local(actor_position)
	var map_position: Vector2i = solid_layer.local_to_map(local_position)
	var tile_data: TileData = solid_layer.get_cell_tile_data(map_position)
	
	if not tile_data:
		return null
		
	return SolidTileData.new(tile_data)
	
