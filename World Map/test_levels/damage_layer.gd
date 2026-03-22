extends TileMapLayer

func apply_effect(player):
		player.get_node("%health").damage(10)
