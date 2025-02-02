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

# save
@onready var path: String = "user:/" + str(get_path()).trim_prefix("/root/Main") + "/data.save"

# character
var character_data = {
	"Player8":
	{
		"name": "Player8",
		"health": 100,
		"attack": 3,
		"defense": 3,
		"level": 10,
		"experience": 0,
		"mana": 10,
		"speed": 1.2,
		"dodge": 10,
	},
	"Player9":
	{
		"name": "Player9",
		"health": 100,
		"attack": 5,
		"defense": 2,
		"level": 10,
		"experience": 0,
		"mana": 100,
		"speed": 1.0,
		"dodge": 30,
	},
	"Enemy9":
	{
		"name": "Enemy9",
		"health": 30,
		"attack": 5,
		"defense": 1,
		"level": 1,
		"experience": 0,
		"mana": 1,
		"speed": 0.8,
		"dodge": 10,
	},
}


func _ready() -> void:
	for cell in character_tile.get_used_cells():
		init_player(cell)
	character_tile.queue_free()

	print(load_game(path))


func _process(delta: float) -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		if player.moving:
			continue
		var previous_position = player.cell_position

		# calculate tween duration
		var tile_data = object_tile.get_cell_tile_data(previous_position)
		if not tile_data:
			tile_data = rail_tile.get_cell_tile_data(previous_position)
		if not tile_data:
			tile_data = ground_tile.get_cell_tile_data(previous_position)
		var speed = tile_data.get_custom_data("speed") * player.data["speed"]
		player.calculate_tween_duration(speed)

		# control
		var target_cell = control(player, tile_data)
		player.set_cell_position(target_cell)
		var present_position = player.cell_position
		control_cart(tile_data, previous_position, present_position)


func control(player, tile_data) -> Vector2:
	var target_cell
	target_cell = player.control()

	# rail
	var previous_position = player.cell_position
	if player.pressed[player.xy_index] and tile_data.get_custom_data("name") == "cart":
		var rail_data = rail_tile.get_cell_tile_data(previous_position)
		if rail_data and "rail" in rail_data.get_custom_data("name"):
			var available_input = []
			for dir in player.inputs:
				if dir in rail_data.get_custom_data("control"):
					available_input.append(player.inputs[dir])
			available_input.erase(-player.previous_component)
			if available_input.size() != 1:
				return target_cell
			var input = available_input[0]
			target_cell = player.cell_position + input
	return target_cell


func control_cart(tile_data, previous_position, present_position) -> void:
	if previous_position == present_position:
		return
	if tile_data.get_custom_data("name") == "cart":
		var rail_data = rail_tile.get_cell_tile_data(present_position)
		var object_data = object_tile.get_cell_tile_data(present_position)
		if not rail_data:
			return
		if rail_data.get_custom_data("name") == "rail_straight":
			if not object_data or object_data.get_custom_data("name") != "cart":
				object_tile.erase_cell(previous_position)
			object_tile.set_cell(present_position, source_id, Vector2(6, 4))
		elif rail_data.get_custom_data("name") == "rail_bent":
			if not object_data or object_data.get_custom_data("name") != "cart":
				object_tile.erase_cell(previous_position)
			object_tile.set_cell(present_position, source_id, Vector2(8, 4))


func init_player(cell):
	var tile_data = character_tile.get_cell_tile_data(cell)
	var name = tile_data.get_custom_data("name")

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
	var data = load_game(path)
	if data.has(name):
		player.data = data[name]
	else:
		player.data = character_data[name]

	player.connect("ray_cast_area", _on_source_ray_cast_target)

	add_child(player)

	player.set_cell_position(Vector2(cell))


func _on_source_ray_cast_target(source, target):
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game(path)


func save_game(path: String) -> void:
	var base_dir = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(base_dir):
		DirAccess.make_dir_recursive_absolute(base_dir)
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		var node_data = node.data
		assert(node_data)
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)


func load_game(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return character_data
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	#for i in save_nodes:
	#	i.queue_free()
	var save_file = FileAccess.open(path, FileAccess.READ)
	var data_dict = {}
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print(
				"JSON Parse Error: ",
				json.get_error_message(),
				" in ",
				json_string,
				" at line ",
				json.get_error_line()
			)
			continue
		var node_data = json.data
		data_dict[node_data["name"]] = node_data
	return data_dict
