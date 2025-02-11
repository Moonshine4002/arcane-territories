extends Area2D
## A 2D controller that moves its parent in a grid pattern.
##
## Inspired: https://kidscancode.org/godot_recipes/4.x/2d/grid_movement/index.html
## Assisted by deepseek.

signal player_request(source: Node, type: String, parameters: Array)

@onready var player = get_parent()

# position
@export var tile_size: int = 16
var cell: Vector2
var moving = false

# control
const INPUTS: Dictionary = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up-left": Vector2.UP + Vector2.LEFT,
	"up-right": Vector2.UP + Vector2.RIGHT,
	"down-left": Vector2.DOWN + Vector2.LEFT,
	"down-right": Vector2.DOWN + Vector2.RIGHT,
}
var xy_index: int = 0
const XY_COMPONENTS: Array[Vector2] = [
	Vector2(1, 0),
	Vector2(0, 1),
]
var previous_input: Vector2 = Vector2.ZERO
var previous_displacement: Vector2 = Vector2.ZERO
var pressed: bool = false
var tween: Tween

# perception
var ray_cast_target = Vector2.UP


func _ready() -> void:
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	player_request.emit(player, "set_texture", [set_sprite_atlas])
	#player_request.emit(player, "move", [move_to_cell, null, 0])


func _process(delta: float) -> void:
	ray_cast_target = ray_cast_target.rotated(PI / 2)
	scan_area_bodyblock(ray_cast_target)
	#player_request.emit(player, "get_control", [control, moving])


func control() -> Vector2:
	var displacement: Vector2 = Vector2.ZERO
	for dir in INPUTS.keys():
		if Input.is_action_pressed(dir):
			displacement += INPUTS[dir]
	if displacement == Vector2.ZERO:
		pressed = false
		previous_input = Vector2.ZERO
		previous_displacement = Vector2.ZERO
		return Vector2.ZERO
	pressed = displacement == previous_input
	previous_input = displacement

	xy_index = (xy_index + 1) % 2
	var component: Vector2 = displacement * XY_COMPONENTS[xy_index]
	if component == Vector2.ZERO:  # check the other component if zero
		component = displacement * XY_COMPONENTS[(xy_index + 1) % 2]
	assert(component != Vector2.ZERO)
	component = component.normalized()

	if scan_area_body(component, false):
		return Vector2.ZERO

	var shift = Input.is_key_pressed(KEY_SHIFT)

	(
		player_request
		. emit(
			player,
			"move",
			[
				move_by_cell_inc,
				component,
				cell,
				{
					"previous_displacement": previous_displacement,
					"pressed": pressed,
					"shift": shift,
				},
			],
		)
	)
	return component


func move_by_cell_inc(cell_inc: Vector2, duration: float, tile_size: int = tile_size) -> void:
	cell += cell_inc
	previous_displacement = cell_inc
	_move_to(player.position + cell_inc * tile_size, duration)


func move_to_cell(cell_abs: Vector2, duration: float, tile_size: int = tile_size) -> void:
	cell = cell_abs
	previous_displacement = cell_abs - cell
	_move_to((cell_abs + Vector2.ONE / 2) * tile_size, duration)


func _move_to(target: Vector2, duration: float) -> void:
	assert(not moving)
	if tween:
		tween.kill()
		tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(player, "position", target, duration)
	moving = true
	#$AnimationPlayer.play(dir)
	await tween.finished
	moving = false


func set_sprite_texture(texture: Texture2D):
	$Sprite2D.texture = texture


func set_sprite_atlas(texture: Texture2D, atlas_cell: Vector2, tile_size: int = tile_size):
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(
		atlas_cell * tile_size,
		Vector2(tile_size, tile_size),
	)
	$Sprite2D.texture = atlas
	#$Sprite2D.scale = Vector2.ONE


func scan_area_body(target_cell_inc: Vector2, emit: bool = true) -> bool:
	return _scan(target_cell_inc, true, true, false, false, emit)


func scan_area(target_cell_inc: Vector2, emit: bool = true) -> bool:
	return _scan(target_cell_inc, true, false, false, false, emit)


func scan_area_bodyblock(target_cell_inc: Vector2, emit: bool = true) -> bool:
	return _scan(target_cell_inc, true, false, false, true, emit)


func scan_body(target_cell_inc: Vector2, emit: bool = true) -> bool:
	return _scan(target_cell_inc, false, true, false, false, emit)


func scan_body_areablock(target_cell_inc: Vector2, emit: bool = true) -> bool:
	return _scan(target_cell_inc, false, true, true, false, emit)


func _scan(
	target_cell_inc: Vector2,
	collide_with_areas: bool,
	collide_with_bodies: bool,
	areas_block: bool = false,
	bodies_block: bool = false,
	emit: bool = true,
	tile_size: float = tile_size,
) -> bool:
	if collide_with_areas or areas_block:
		$RayCast2D.collide_with_areas = true
	else:
		$RayCast2D.collide_with_areas = false
	if collide_with_bodies or bodies_block:
		$RayCast2D.collide_with_bodies = true
	else:
		$RayCast2D.collide_with_bodies = false
	$RayCast2D.target_position = target_cell_inc * tile_size
	$RayCast2D.force_raycast_update()
	if not $RayCast2D.is_colliding():
		return false
	var collider = $RayCast2D.get_collider()
	if areas_block and collider is Area2D:
		return false
	if bodies_block and collider is not Area2D:  #PhysicsBody2D:
		return false
	if emit:
		player_request.emit(player, "ray_cast", [collider])
	return true
