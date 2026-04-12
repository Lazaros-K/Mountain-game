class_name TileMapManager
extends TileMapLayer
## 

@export var tilemap_id: String
@export var debug_mode: bool = false

@export var top_left_cell_coords: Vector2i
@export var bottom_right_cell_coords: Vector2i
var terrain_tilemaps: Array[TileMapLayer] = Array([], TYPE_OBJECT, "TileMapLayer", null)
var special_tiles: Dictionary = {}

func _ready() -> void:
	# create resource tilemap layers using the resource tileset
	var dual_tileset: TileSet = load(ResourceTiles.DUAL_TILESET_FILE)
	var dual_tilemap_pos: Vector2 = self.tile_set.tile_size/2.0
	
	for terrain_id: int in range(0,ResourceTiles.TERRAIN_MAP.size()) :
		if ResourceTiles.TERRAIN_MAP.has(terrain_id) :
			terrain_tilemaps.append(TileMapLayer.new())
			terrain_tilemaps[terrain_id].tile_set = dual_tileset
			terrain_tilemaps[terrain_id].position = dual_tilemap_pos
			add_child(terrain_tilemaps[terrain_id])
	
	# make operational tiles invisible while in game
	if not debug_mode :
		self.self_modulate.a = 0
	
	update_map_resources(top_left_cell_coords,bottom_right_cell_coords)

## Returns the SolidTileData of the tile in actor_position
func get_tile_data(actor_position: Vector2) -> TerrainTileData :
	var tile_data: TileData = self.get_cell_tile_data(self.local_to_map(actor_position))
	if not tile_data :
		return null
	return TerrainTileData.new(tile_data);

## Updates all resource tiles in a box
func update_map_resources(top_left: Vector2i, bottom_right: Vector2i) -> void :
	for x: int in range(top_left.x,bottom_right.x+1) :
		for y: int in range(top_left.y,bottom_right.y+1) :
			var pos: Vector2i = Vector2i(x,y)
			if self.get_cell_source_id(pos) == -1 :
				continue
			var tile_id: int = self.get_cell_tile_data(pos).get_custom_data("tile_id")
			
			if ResourceTiles.TERRAIN_MAP.has(tile_id) :
				var terrain_id: int = ResourceTiles.TERRAIN_MAP.get(tile_id)
				var resource_cell_positions: Array[Vector2i] = [pos,Vector2i(x-1,y),Vector2i(x,y-1),Vector2i(x-1,y-1)]
				terrain_tilemaps[terrain_id].set_cells_terrain_connect(resource_cell_positions,0,terrain_id)
			elif ResourceTiles.SPECIAL_MAP.has(tile_id) :
				var special_id: int = ResourceTiles.SPECIAL_MAP.get(tile_id)
				place_special_tile(pos,special_id)
				

## Places a special tile in the correct tilemap postion and adds it's reference to the special_tiles dictionary
func place_special_tile(pos: Vector2i, special_id: int) -> void :
	var factory: SpecialTileFactory = ResourceTiles.get_special_tile_factory(special_id)
	var special_tile: Node2D = factory.create_special_tile(special_id,self,pos)
	add_child(special_tile)
	special_tiles.set(pos,special_tile)
	# calculate the postion relative to the TileMap Manager
	@warning_ignore("integer_division")
	special_tile.position = (self.tile_set.tile_size.x*pos) + self.tile_set.tile_size/2

## Removes a tile and updates the corrisponding layer
func remove_terrain(actor_position: Vector2) -> void :
	var pos: Vector2i = self.local_to_map(actor_position)
	
	var terrain_id: int = ResourceTiles.TERRAIN_MAP.get(self.get_cell_tile_data(pos).get_custom_data("tile_id"))
	self.set_cell(pos,-1)
	# removes/resets resource cell
	terrain_tilemaps[terrain_id].set_cell(pos,-1)
	terrain_tilemaps[terrain_id].set_cell(pos+Vector2i(0,-1),-1)
	terrain_tilemaps[terrain_id].set_cell(pos+Vector2i(-1,0),-1)
	terrain_tilemaps[terrain_id].set_cell(pos+Vector2i(-1,-1),-1)
	update_map_resources(pos+Vector2i(-1,-1),pos+Vector2i(1,1))
