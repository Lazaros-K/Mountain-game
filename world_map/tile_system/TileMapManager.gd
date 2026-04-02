class_name TileMapManager
extends TileMapLayer
## 

@export var tilemap_id: String
@export var debug_mode: bool = false

@export var top_left_cell_coords: Vector2i
@export var bottom_right_cell_coords: Vector2i
var res_tilemaps: Array[TileMapLayer] = Array([], TYPE_OBJECT, "TileMapLayer", null)

func _ready() -> void:
    # create resource tilemap layers using the resource tileset
    var res_tileset: TileSet = load("res://world_map/tile_system/resource_tile_set/resource_tile_set.tres")
    var res_tilemap_pos: Vector2 = self.tile_set.tile_size/2.0
    for terrain_id: int in range(0,res_tileset.get_source_count()) :
        res_tilemaps.append(TileMapLayer.new())
        res_tilemaps[terrain_id].tile_set = res_tileset
        res_tilemaps[terrain_id].position = res_tilemap_pos
        add_child(res_tilemaps[terrain_id])
    
    # decoration tilemap
    
    # make operational tiles invisible while in game
    if not debug_mode :
        self.self_modulate.a = 0
    
    update_map_resources(top_left_cell_coords,bottom_right_cell_coords)

## Returns the SolidTileData of the tile in actor_position
func get_tile_data(actor_position: Vector2) -> SolidTileData :
    var tile_data: TileData = self.get_cell_tile_data(self.local_to_map(actor_position))
    if not tile_data :
        return null
    return SolidTileData.new(tile_data);

## Updates all resource tiles in a box
func update_map_resources(top_left: Vector2i, bottom_right: Vector2i) -> void :
    
    for x: int in range(top_left.x,bottom_right.x+1) :
        for y: int in range(top_left.y,bottom_right.y+1) :
            var pos: Vector2i = Vector2i(x,y)
            if self.get_cell_source_id(pos) == -1 :
                continue
            var resource_cell_positions: Array[Vector2i] = [pos,Vector2i(x-1,y),Vector2i(x,y-1),Vector2i(x-1,y-1)]
            var terrain_id: int = self.get_cell_tile_data(pos).get_custom_data("tile_id")
            res_tilemaps[terrain_id].set_cells_terrain_connect(resource_cell_positions,0,terrain_id)

## Removes a tile and updates the corrisponding layer
func remove_tile(actor_position: Vector2) -> void :
    var pos: Vector2i = self.local_to_map(actor_position)
    var terrain_id: int = self.get_cell_tile_data(pos).get_custom_data("tile_id")
    self.set_cell(pos,-1) 
    # removes/resets resource cell
    res_tilemaps[terrain_id].set_cell(pos,-1)
    res_tilemaps[terrain_id].set_cell(pos+Vector2i(0,-1),-1)
    res_tilemaps[terrain_id].set_cell(pos+Vector2i(-1,0),-1)
    res_tilemaps[terrain_id].set_cell(pos+Vector2i(-1,-1),-1)
    update_map_resources(pos+Vector2i(-1,-1),pos+Vector2i(1,1))
