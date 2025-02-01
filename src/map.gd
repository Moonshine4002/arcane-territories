extends Node2D

var current_scene: PackedScene


func _ready() -> void:
	current_scene = load("res://map/kenney_tiny-dungeon/level_1.tscn")
	add_current_scene()


func _process(delta: float) -> void:
	pass


func add_current_scene():
	var current_scene = current_scene.instantiate()
	add_child(current_scene)
