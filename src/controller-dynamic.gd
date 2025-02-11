extends Controller


func _ready() -> void:
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	player_request.emit(player, "set_texture", [set_sprite_atlas])
	#player_request.emit(player, "move", [move_to_cell, null, 0])


func _process(delta: float) -> void:
	ray_cast_target = ray_cast_target.rotated(PI / 2)
	scan_area_bodyblock(ray_cast_target)
	player_request.emit(player, "get_control", [control, moving])
