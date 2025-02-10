extends Node

# data
var data: Dictionary


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func connect_controller(fun: Callable) -> void:
	$Controller.connect("player_request", fun)
