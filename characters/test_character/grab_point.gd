class_name MapPoint
extends Marker2D

var current_map_fragment: TileMapManager = null
@onready var detection_area: Area2D = $Area2D

func _ready() -> void:
	detection_area.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var parent = area.owner
	
	if parent is TileMapManager:
		current_map_fragment = parent

func get_data() -> SolidTileData:
	if current_map_fragment != null:
		return current_map_fragment.get_tile_data(global_position)
		
	return null
