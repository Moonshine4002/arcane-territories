extends Node2D

@export var player_scene: PackedScene

var source_id = 0

@onready var tile: TileMapLayer = $Character


func _ready() -> void:
	for cell in tile.get_used_cells():
		var tile_data = tile.get_cell_tile_data(cell)
		if "Player" in tile_data.get_custom_data("name"):
			init_player(cell)
	tile.clear()


func _process(delta: float) -> void:
	pass


func init_player(cell):
	var player = player_scene.instantiate()

	var tile_set = tile.tile_set
	var atlas_source: TileSetAtlasSource = tile_set.get_source(source_id)

	var texture := AtlasTexture.new()
	texture.atlas = atlas_source.texture
	texture.region = Rect2(
		tile.get_cell_atlas_coords(cell) * tile.tile_set.tile_size,
		tile.tile_set.tile_size,
	)
	player.get_node("Sprite2D").texture = texture
	player.get_node("Sprite2D").scale = Vector2.ONE

	add_child(player)

	player.set_cell_position(Vector2(cell))
