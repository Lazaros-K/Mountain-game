class_name MapPoint
extends Marker2D

var map_fragment: TileMapManager = null 
@onready var detection_area: Area2D = $Area2D

func _ready() -> void:
	detection_area.area_entered.connect(_on_area_entered)

##Checks for Area2D specifically named fragment_area and
##returns the map_fragment
func _on_area_entered(area: Area2D) -> void:
	if area.name == "fragment_area":
		var current_node = area.get_parent()
		
		while current_node != null:
			if current_node is TileMapManager:
				map_fragment = current_node
				## print("Found TileMapManager: ", map_fragment.name) -- For tests
				break 
			
			current_node = current_node.get_parent()


func get_data() -> TileMapManager:
	if map_fragment:
		## print("Returned TileMapManager: ", map_fragment.name) -- For tests
		return map_fragment
	else:
		return null
	
