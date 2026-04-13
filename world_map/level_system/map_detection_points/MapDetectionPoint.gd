class_name MapDetectionPoint
extends Marker2D

var map_fragment: MapFragment = null 

func _ready() -> void:
	# create Area2D
	var area: Area2D = Area2D.new()
	area.area_entered.connect(_on_area_entered)
	add_child(area)
	
	# create CollisionShape2D (one pixel Rect)
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(1, 1)
	collision_shape.shape = shape
	area.add_child(collision_shape)
	
	# set collision mask to detect map fragments
	area.collision_layer = 0
	area.collision_mask = 0
	area.set_collision_mask_value(CollisionLayers.MAP_FRAGMENTS, true)

## Set the map fragment when entering a new one
func _on_area_entered(area: Area2D) -> void:
	var parent_node: Node = area.get_parent()
	if parent_node is MapFragment:
		map_fragment = parent_node as MapFragment

func get_data() -> TerrainTileData:
	return map_fragment.get_tile_data(global_position)
