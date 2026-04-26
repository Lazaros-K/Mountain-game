class_name MapFragment
extends Node2D

@export_group("Map Fragment info")
@export var map_fragment_id: String
@export var difficulty: int = 1

@export_group("Map Fragment setup")
@export var tile_map: TileMapManager = null
@export var top_right_corner: Vector2i = Vector2i.ZERO
@export var entrance_marker: Marker2D = null
@export var exit_marker: Marker2D = null

var fragment_index: int

var entrance_pos: Vector2
var exit_pos: Vector2

func _ready() -> void:
	# calculate positions
	var tile_pos: Vector2i = tile_map.local_to_map(entrance_marker.position)
	entrance_pos = tile_map.tile_set.tile_size * tile_pos
	tile_pos = tile_map.local_to_map(exit_marker.position) + Vector2i(1,0)
	exit_pos = tile_map.tile_set.tile_size * tile_pos
	
	if not tile_map or not entrance_marker or not exit_marker or top_right_corner == Vector2i.ZERO:
		printerr("Map Fragment isn't set up properly")
		get_tree().quit(1)
	
	setup_dynamic_mask()

## Function for creating the detection Area2D's by script
func setup_dynamic_mask() -> void:
	## Tilemap limits
	var tile_size: Vector2i = tile_map.tile_set.tile_size
	
	var width: int = (top_right_corner.x+1) * tile_size.x
	var height: int = top_right_corner.y * tile_size.y
	
	## Area2D Creation
	var area: Area2D = Area2D.new()
	area.name = "fragment_area"
	area.collision_layer = 0
	area.collision_mask = 0
	area.set_collision_layer_value(8, true)
	
	## CollisionShape2D Creation
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(width+1, height+1)
	collision_shape.shape = rect_shape
	
	collision_shape.position = Vector2((rect_shape.size.x / 2.0),-(rect_shape.size.y / 2.0))
	
	area.add_child(collision_shape)
	add_child(area)

## Returns the SolidTileData of the tile in actor_position
func get_tile_data(actor_position: Vector2) -> TerrainTileData :
	var local_position: Vector2 = tile_map.to_local(actor_position)
	var map_position: Vector2 = tile_map.local_to_map(local_position)
	return tile_map.get_tile_data(map_position)

func get_entrance_pos() -> Vector2 :
	return entrance_pos

func get_exit_pos() -> Vector2 :
	return exit_pos
