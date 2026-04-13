class_name TileMapManager
extends TileMapLayer
## Manages the tiles of a complex tilemap implementation,
## featuring a dual grid, and special tile scenes

@export var debug_mode: bool = false

var terrain_tilemaps: Array[TileMapLayer] = Array([], TYPE_OBJECT, "TileMapLayer", null)
var special_tiles: Dictionary = {}

func get_tileid(pos: Vector2i) -> int :
	var tile_data: TileData = self.get_cell_tile_data(pos)
	return tile_data.get_custom_data("tile_id") if tile_data else -1

func get_tile_data(pos: Vector2i) -> TerrainTileData :
	var tile_data: TileData = self.get_cell_tile_data(pos)
	return TerrainTileData.new(tile_data) if tile_data else null

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
	
	# Updates the every tile in the tile map
	update_tile_resources(get_used_cells())

## Updates all resource tiles in the given array of positions
func update_tile_resources(tiles: Array[Vector2i]) -> void :
	for i: int in tiles.size() :
		
		var pos: Vector2i = tiles[i]
		if self.get_cell_source_id(pos) == -1 :
			continue
			
		var tile_id: int = get_tileid(pos)
		
		if ResourceTiles.TERRAIN_MAP.has(tile_id) :
			var terrain_id: int = ResourceTiles.TERRAIN_MAP.get(tile_id)
			# add all surrounding cells of the dual map in an array
			var resource_cell_positions: Array[Vector2i] = [pos,Vector2i(pos.x-1,pos.y),Vector2i(pos.x,pos.y-1),Vector2i(pos.x-1,pos.y-1)]
			terrain_tilemaps[terrain_id].set_cells_terrain_connect(resource_cell_positions,0,terrain_id)
			
		elif ResourceTiles.SPECIAL_MAP.has(tile_id) :
			var special_id: int = ResourceTiles.SPECIAL_MAP.get(tile_id)
			place_special_tile(pos,special_id)
		

## Places a special tile in the correct tilemap postion and adds it's reference to the special_tiles dictionary
func place_special_tile(pos: Vector2i, special_id: int) -> void :
	var factory: SpecialTileFactory = ResourceTiles.get_special_tile_factory(special_id)
	
	# uses factory to create special tiles
	var special_tile: Node2D = factory.create_special_tile(special_id,self,pos)
	add_child(special_tile)
	special_tiles.set(pos,special_tile)
	
	# calculate the postion relative to the TileMap Manager
	@warning_ignore("integer_division")
	special_tile.position = (self.tile_set.tile_size.x*pos) + self.tile_set.tile_size/2

## Removes a tile and updates the corrisponding layer
func remove_terrain(actor_position: Vector2) -> void :
	var pos: Vector2i = self.local_to_map(actor_position)
	
	var terrain_id: int = ResourceTiles.TERRAIN_MAP[get_tileid(pos)]
	self.set_cell(pos,-1)
	# removes/resets resource cell
	terrain_tilemaps[terrain_id].set_cell(pos,-1)
	terrain_tilemaps[terrain_id].set_cell(pos+Vector2i(0,-1),-1)
	terrain_tilemaps[terrain_id].set_cell(pos+Vector2i(-1,0),-1)
	terrain_tilemaps[terrain_id].set_cell(pos+Vector2i(-1,-1),-1)
	update_tile_resources([pos,Vector2i(pos.x-1,pos.y),Vector2i(pos.x,pos.y-1),Vector2i(pos.x-1,pos.y-1)])
