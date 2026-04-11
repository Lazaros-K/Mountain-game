class_name MapDetectionPoint
extends Marker2D

var map_fragment: TileMapManager = null 
@onready var detection_area: Area2D = $Area2D

func _ready() -> void:
	detection_area.area_entered.connect(_on_area_entered)

## Checks for Area2D collisions at mask 8 for map fragments
## and returns the map_fragment
func _on_area_entered(area: Area2D) -> void:
	var parent_node: Node = area.get_parent()
		
	if parent_node is TileMapManager:
		map_fragment = parent_node as TileMapManager
			


func get_data() -> TileMapManager:
	return map_fragment
	
