class_name CharacterMapPoint
extends MapDetectionPoint

## sends a signal each time it detectes a new map fragment
signal map_fragment_changed(new_index: int)

## Set the map fragment when entering a new one
func _on_area_entered(area: Area2D) -> void:
	var parent_node: Node = area.get_parent()
	
	if parent_node is not MapFragment:
		return
	var new_map_fragment: MapFragment = parent_node as MapFragment
	
	if new_map_fragment != map_fragment:
		map_fragment = new_map_fragment
		map_fragment_changed.emit(map_fragment.fragment_index)
