TILE CREATION

To create a new tile you first need to define an operational tile in the tileset.
Operational tiles hold the TerrainTileData, And an id.

The id of a tile is used to identify what kind of tile it is.
The id needs to also be added to the Tiles class ID enum.
Then a map of wha that ID is needs to be added to the ResourceTiles class dictionaries.
Finally,
1) if the new tile is a plain dual grid textured tile,
   you need to define the texture and terrain in the tileset.
2) if the new tile is a special tile,
   you can either create a simple return on the ResourceTiles class,
   or if the tile has different versions of itself based on surounding terrain,
   rotation, or anything else you can extend the SpecialTileFactory.
