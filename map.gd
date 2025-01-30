extends Node2D

@onready var tile: TileMapLayer = $Level1.tile


func _ready() -> void:
	for cell in tile.get_used_cells():
		var tile_data = tile.get_cell_tile_data(cell)
		if tile_data.get_custom_data("name") == "Player9":
			$Player.set_cell_position(Vector2(cell))

			var tile_set = tile.tile_set
			var atlas_source: TileSetAtlasSource = tile_set.get_source($Level1.source_id)

			var texture := AtlasTexture.new()
			texture.atlas = atlas_source.texture
			texture.region = Rect2(
				tile.get_cell_atlas_coords(cell) * tile.tile_set.tile_size,
				tile.tile_set.tile_size,
			)
			$Player/Sprite2D.texture = texture
			$Player/Sprite2D.scale = Vector2.ONE
	$Level1.clear_map()


func _process(delta: float) -> void:
	pass
