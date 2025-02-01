extends Node2D

@export var player_scene: PackedScene

# texture
var source_id = 0
@onready var character_tile: TileMapLayer = $Character
@onready var ground_tile: TileMapLayer = $Ground
@onready var rail_tile: TileMapLayer = $Rail
@onready var object_tile: TileMapLayer = $Object
@onready var tile_set = character_tile.tile_set
@onready var atlas_source: TileSetAtlasSource = tile_set.get_source(source_id)


func _ready() -> void:
	for cell in character_tile.get_used_cells():
		init_player(cell)
	character_tile.clear()


func _process(delta: float) -> void:
	for player in get_tree().get_nodes_in_group("players"):
		var tile_data = object_tile.get_cell_tile_data(player.cell_position)
		if not tile_data:
			tile_data = rail_tile.get_cell_tile_data(player.cell_position)
		if not tile_data:
			tile_data = ground_tile.get_cell_tile_data(player.cell_position)
		var speed = tile_data.get_custom_data("speed")
		player.calculate_tween_duration(speed)

		var previous_position = player.cell_position
		player.control()
		var present_position = player.cell_position

		if previous_position == present_position:
			continue
		if tile_data.get_custom_data("name") == "cart":
			var rail_data = rail_tile.get_cell_tile_data(present_position)
			var object_data = object_tile.get_cell_tile_data(present_position)
			if !rail_data:
				continue
			if rail_data.get_custom_data("name") == "rail_straight":
				if !object_data or object_data.get_custom_data("name") != "cart":
					object_tile.erase_cell(previous_position)
				object_tile.set_cell(present_position, source_id, Vector2i(6, 4))
			elif rail_data.get_custom_data("name") == "rail_bent":
				if !object_data or object_data.get_custom_data("name") != "cart":
					object_tile.erase_cell(previous_position)
				object_tile.set_cell(present_position, source_id, Vector2i(8, 4))


func init_player(cell):
	var tile_data = character_tile.get_cell_tile_data(cell)
	var name = tile_data.get_custom_data("name")
	if "Player" not in name:
		return

	var player = player_scene.instantiate()

	var texture := AtlasTexture.new()
	texture.atlas = atlas_source.texture
	texture.region = Rect2(
		character_tile.get_cell_atlas_coords(cell) * character_tile.tile_set.tile_size,
		character_tile.tile_set.tile_size,
	)
	player.get_node("Sprite2D").texture = texture
	player.get_node("Sprite2D").scale = Vector2.ONE

	player.name = name
	player.data = {
		"health": 100,
		"attack": 10,
		"defense": 5,
		"level": 1,
		"experience": 0,
		"mana": 10,
		"speed": 1,
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
