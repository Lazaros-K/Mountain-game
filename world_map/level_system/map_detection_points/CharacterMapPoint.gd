class_name CharacterMapPoint
extends MapDetectionPoint

## sends a signal each time it detectes a new map fragment
signal map_fragment_changed(new_index: int)

## Set the map fragment when entering a new one
func _on_area_entered(area: Area2D) -> void:
	var parent_node: Node = area.get_parent()
	
	if parent_node is not TileMapManager:
		return
	var new_map_fragment: TileMapManager = parent_node as TileMapManager
	
	if new_map_fragment != map_fragment:
		map_fragment = new_map_fragment
		map_fragment_changed.emit(map_fragment.fragment_index)
