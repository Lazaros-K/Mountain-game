class_name ResourceTiles

enum TERRAIN {
	SNOW = 0,
	REGOLITH,
	SLATE,
	ICE
}

enum SPECIAL {
	SPIKE_UP = 0,
	SPIKE_RIGHT,
	SPIKE_DOWN,
	SPIKE_LEFT
}

const DUAL_TILESET_FILE: String = "uid://bc8c5ckgu0eoc"

const TERRAIN_MAP: Dictionary = {
	Tiles.ID.SNOW : TERRAIN.SNOW,
	Tiles.ID.REGOLITH : TERRAIN.REGOLITH,
	Tiles.ID.SLATE : TERRAIN.SLATE,
	Tiles.ID.ICE : TERRAIN.ICE
}

const SPECIAL_MAP: Dictionary = {
	Tiles.ID.SPIKE_UP : SPECIAL.SPIKE_UP,
	Tiles.ID.SPIKE_RIGHT : SPECIAL.SPIKE_RIGHT,
	Tiles.ID.SPIKE_DOWN : SPECIAL.SPIKE_DOWN,
	Tiles.ID.SPIKE_LEFT : SPECIAL.SPIKE_LEFT
}

static func get_special_tile_factory(special_id: int) -> SpecialTileFactory :
	if special_id >= SPECIAL.SPIKE_UP and special_id <= SPECIAL.SPIKE_LEFT:
		return SpikeFactory.new()
	return null;
