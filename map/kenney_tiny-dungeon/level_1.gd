extends Node2D

signal level_request(source: Node, type: String, parameters: Array)

@export var player_scene: PackedScene

# tile map
var source_id = 0
@onready var ground_tile: TileMapLayer = $Ground
@onready var rail_tile: TileMapLayer = $Rail
@onready var character_tile: TileMapLayer = $Character
@onready var object_tile: TileMapLayer = $Object
@onready var tile_set = ground_tile.tile_set
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
		"speed": 10,
		"dodge": 10,
		"weapon": [Vector2(10, 8), Vector2(5, 8)],
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
		"speed": 5,
		"dodge": 30,
		"weapon": [Vector2(9, 10)],
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
		"speed": 3.3,
		"dodge": 10,
		"weapon": [],
	},
}


func _ready() -> void:
	if name != "Level1":
		character_tile.queue_free()
		return
	for cell in character_tile.get_used_cells():
		add_player(cell)
	character_tile.queue_free()

	print(load_game(path))


func _process(delta: float) -> void:
	pass


func connect_level(fun: Callable) -> void:
	self.connect("level_request", fun)


func add_player(cell: Vector2, player = null):
	if not player:
		player = player_scene.instantiate()

		var tile_data = character_tile.get_cell_tile_data(cell)
		var name = tile_data.get_custom_data("name")
		player.name = name

		var data = load_game(path)
		if data.has(name):
			player.data = data[name]
		else:
			return
			#player.data = character_data[name]

		#player.data["cell"] = cell
		player.data["cell_atlas_coords"] = character_tile.get_cell_atlas_coords(cell)

		if player.name == "Player9":
			player.controller_switch_dynamic()
			var camera = Camera2D.new()
			camera.name = "Camera"
			camera.limit_left = 0
			camera.limit_top = 0
			#camera.position_smoothing_enabled = true
			#camera.position_smoothing_speed = 0
			player.get_node("Controller").add_child(camera)  # TODO: remove

	var controller = player.get_node("Controller")  # TODO: remove
	if player:
		controller.pressed = false
		controller.last_input = Vector2.ZERO
		controller.last_disp = Vector2.ZERO

	player.connect_controller(_on_controller_player_request)

	add_child(player)
	controller.move_to_cell(cell, 0)
	controller.z_index = 1


func remove_player(player: Node):
	var controller = player.get_node("Controller")  # TODO: remove
	var camera = controller.get_node("Camera")  # TODO: remove
	player.disconnect_controller(_on_controller_player_request)
	remove_child(player)


func _on_controller_player_request(source: Node, type: String, parameters: Array) -> void:
	var player = source
	match type:
		"get_control":
			var fun = parameters[0]
			var moving = parameters[1]
			if moving:
				return
			fun.call()
		"move":
			var fun = parameters[0]
			var component = parameters[1]
			var cell = parameters[2]
			assert(component != Vector2.ZERO)
			#if not component:  # _ready
			#	fun.call(player.data["cell"], cell)
			#	return

			var input_para = parameters[3]
			var last_disp = input_para["last_disp"]
			var pressed = input_para["pressed"]
			var shift = input_para["shift"]

			var tile_data = control_get_tile_data(player, cell)
			var speed = tile_data.get_custom_data("speed")
			speed *= player.data["speed"]
			if shift:
				speed *= 0.3

			component = control_rail(player, cell, tile_data, component, last_disp)  #, pressed)
			var present_cell = cell + component

			var teleport_flag = false
			if cell in [Vector2(12, 0), Vector2(13, 0)] and component == Vector2.UP:
				teleport_flag = true
				present_cell.y = 25
				level_request.emit(self, "teleport", [player, "up", present_cell])
			elif cell in [Vector2(12, 25), Vector2(13, 25)] and component == Vector2.DOWN:
				teleport_flag = true
				present_cell.y = 0
				level_request.emit(self, "teleport", [player, "down", present_cell])
			elif cell in [Vector2(0, 13), Vector2(0, 14)] and component == Vector2.LEFT:
				teleport_flag = true
				present_cell.x = 25
				level_request.emit(self, "teleport", [player, "left", present_cell])
			elif cell in [Vector2(25, 13), Vector2(25, 14)] and component == Vector2.RIGHT:
				teleport_flag = true
				present_cell.x = 0
				level_request.emit(self, "teleport", [player, "right", present_cell])
			if teleport_flag:
				return

			fun.call(component, 1 / speed)

		"set_texture":
			var fun = parameters[0]
			fun.call(
				atlas_source.texture, [player.data["cell_atlas_coords"]] + player.data["weapon"]
			)
			for i in range(len(player.data["weapon"])):
				i = i + 1
				var weapon = player.get_node("Controller").get_node(var_to_str(i))
				if i == 1:
					weapon.offset += Vector2(8, 2)
				elif i == 2:
					weapon.offset += Vector2(-8, 2)
		"ray_cast":
			var target = parameters[0].get_parent()
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
		#"add_player":
		#	add_child(player)
		#"remove_player":
		#	player.queue_free()
		_:
			assert(false)


func control_get_tile_data(player: Node, cell: Vector2) -> TileData:
	var tile_data = object_tile.get_cell_tile_data(cell)
	if not tile_data:
		tile_data = rail_tile.get_cell_tile_data(cell)
	if not tile_data:
		tile_data = ground_tile.get_cell_tile_data(cell)
	return tile_data


func control_rail(
	player: Node,
	cell: Vector2,
	tile_data: TileData,
	component: Vector2,
	last_disp: Vector2,
	#pressed: bool,
) -> Vector2:
	#if pressed:
	#	assert(last_disp != Vector2.ZERO)
	#	if not player.get_node("Controller").scan_area_body(last_disp, false):  # TODO: remove
	#		component = last_disp

	if tile_data.get_custom_data("name") != "cart":
		return component

	var rail_data = rail_tile.get_cell_tile_data(cell)
	assert(rail_data)
	assert("rail" in rail_data.get_custom_data("name"))
	var available_input = []
	var rail_control = rail_data.get_custom_data("control")
	var INPUTS = player.get_node("Controller").INPUTS  # TODO: remove
	for dir in INPUTS.keys():
		if dir in rail_control:
			available_input.append(INPUTS[dir])
	available_input.erase(-last_disp)
	if last_disp == Vector2.ZERO and component in available_input:
		var present_cell = cell + component
		control_cart(tile_data, cell, present_cell)
		return component
	if available_input.size() != 1:
		return component
	component = available_input[0]

	var present_cell = cell + component
	control_cart(tile_data, cell, present_cell)

	return component


func control_cart(tile_data: TileData, cell: Vector2, present_cell: Vector2) -> void:
	if cell == present_cell:
		return
	if tile_data.get_custom_data("name") != "cart":
		return
	var rail_data = rail_tile.get_cell_tile_data(present_cell)
	var present_data = object_tile.get_cell_tile_data(present_cell)
	if not rail_data:
		return
	if present_data and present_data.get_custom_data("name") == "cart":
		return
	var atlas_coords: Vector2
	if rail_data.get_custom_data("name") == "rail_straight":
		atlas_coords = Vector2(6, 4)
	elif rail_data.get_custom_data("name") == "rail_bent":
		atlas_coords = Vector2(8, 4)
	_tile_move_to(object_tile, cell, present_cell, atlas_coords)


func _tile_move_to(
	layer: TileMapLayer, cell: Vector2, present_cell: Vector2, atlas_coords = null
) -> void:
	var tile_data := layer.get_cell_tile_data(cell)
	if atlas_coords == null:
		atlas_coords = layer.get_cell_atlas_coords(cell)
	layer.erase_cell(cell)
	layer.set_cell(present_cell, source_id, atlas_coords)


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
		assert(node_data.has("name"))
		data_dict[node_data["name"]] = node_data
	return data_dict
