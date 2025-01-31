extends Node2D

@export var player_scene: PackedScene

# texture
var source_id = 0
@onready var tile: TileMapLayer = $Character
@onready var tile_set = tile.tile_set
@onready var atlas_source: TileSetAtlasSource = tile_set.get_source(source_id)


func _ready() -> void:
	for cell in tile.get_used_cells():
		init_player(cell)
	tile.clear()


func _process(delta: float) -> void:
	pass


func init_player(cell):
	var tile_data = tile.get_cell_tile_data(cell)
	var name = tile_data.get_custom_data("name")
	if "Player" not in name:
		return

	var player = player_scene.instantiate()

	var texture := AtlasTexture.new()
	texture.atlas = atlas_source.texture
	texture.region = Rect2(
		tile.get_cell_atlas_coords(cell) * tile.tile_set.tile_size,
		tile.tile_set.tile_size,
	)
	player.get_node("Sprite2D").texture = texture
	player.get_node("Sprite2D").scale = Vector2.ONE

	player.name = name
	player.data = {
		"health": 100,
		"attack": 10,
		"defense": 9,
		"level": 1,
		"experience": 0,
		"mana": 10,
		"speed": 10,
		"dodge": 10,
	}

	player.connect("ray_cast_area", on_source_ray_cast_target)

	add_child(player)

	player.set_cell_position(Vector2(cell))


func on_source_ray_cast_target(source, target):
	print(source, " hit ", target)
	print("source.name = ", source.name)
	if randf() * 100 < target.data["dodge"]:
		print(target.name, " dodged")
	else:
		target.data["health"] -= source.data["attack"] - target.data["defense"]
	print("source.data.health = ", source.data["health"])
	if target.data["health"] <= 0:
		print(target.name, " is defeated")
		target.queue_free()
