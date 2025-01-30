extends Node2D

var source_id = 0
@onready var tile: TileMapLayer = $Character


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func clear_map():
	tile.clear()


func set_cell(map_coords, atlas_coords):
	tile.set_cell(map_coords, source_id, atlas_coords)
