extends Node2D

signal map_request(source: Node, type: String, parameters: Array)

var scenes := {}
var scenes_connection := {}


func _ready() -> void:
	add_current_scene("Level1", "res://map/kenney_tiny-dungeon/level_1.tscn")
	scenes["Level1"].connect_level(_on_level_level_request)
	add_current_scene("Level12", "res://map/kenney_tiny-dungeon/level_2.tscn")
	scenes["Level12"].position = Vector2(16 * 25, 16 * 0)
	scenes["Level12"].connect_level(_on_level_level_request)
	add_current_scene("Level13", "res://map/kenney_tiny-dungeon/level_3.tscn")
	scenes["Level13"].position = Vector2(16 * 0, 16 * 25)
	scenes["Level13"].connect_level(_on_level_level_request)
	add_current_scene("Level14", "res://map/kenney_tiny-dungeon/level_4.tscn")
	scenes["Level14"].position = Vector2(16 * 25, 16 * 25)
	scenes["Level14"].connect_level(_on_level_level_request)
	scenes_connection["Level1"] = {
		"up": null,
		"down": scenes["Level13"],
		"left": null,
		"right": scenes["Level12"],
	}
	scenes_connection["Level12"] = {
		"up": null,
		"down": scenes["Level14"],
		"left": scenes["Level1"],
		"right": null,
	}
	scenes_connection["Level13"] = {
		"up": scenes["Level1"],
		"down": null,
		"left": null,
		"right": scenes["Level14"],
	}
	scenes_connection["Level14"] = {
		"up": scenes["Level12"],
		"down": null,
		"left": scenes["Level13"],
		"right": null,
	}


func _process(delta: float) -> void:
	pass


func connect_map(fun: Callable) -> void:
	self.connect("map_request", fun)


func add_current_scene(name: String, path: String):
	var current_scene = load(path).instantiate()
	current_scene.name = name
	scenes[name] = current_scene
	add_child(current_scene)


func _on_level_level_request(source: Node, type: String, parameters: Array) -> void:
	match type:
		"teleport":
			var player = parameters[0]
			var case = parameters[1]
			var cell = parameters[2]
			var target: Node = scenes_connection[source.name][case]
			if not target:
				return
			source.remove_player(player)
			target.add_player(cell, player)
		"display":
			map_request.emit(source, type, parameters)
		_:
			assert(false)
