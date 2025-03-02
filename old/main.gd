extends Node2D


func _ready() -> void:
	$Map.connect_map(_on_map_map_request)


func _process(delta: float) -> void:
	pass


func _on_map_map_request(source: Node, type: String, parameters: Array) -> void:
	match type:
		"display":
			print(parameters)
			$HUD.display(parameters)
		_:
			assert(false)
