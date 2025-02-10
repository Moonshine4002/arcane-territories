extends Node

# data
var data: Dictionary


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func connect_controller(fun: Callable) -> void:
	$Controller.connect("player_request", fun)


func controller_switch_dynamic() -> void:
	$Controller.set_script(load("res://src/controller-dynamic.gd"))
