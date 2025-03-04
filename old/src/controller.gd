extends Area2D
class_name Controller
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
var last_input: Vector2 = Vector2.ZERO
var last_disp: Vector2 = Vector2.ZERO
var pressed: bool = false
var tween: Tween

# perception
var ray_cast_target = Vector2.UP


func control() -> Vector2:
	var disp: Vector2 = Vector2.ZERO
	for dir in INPUTS.keys():
		if Input.is_action_pressed(dir):
			disp += INPUTS[dir]
	if disp == Vector2.ZERO:
		pressed = false
		last_input = Vector2.ZERO
		last_disp = Vector2.ZERO
		return Vector2.ZERO
	pressed = disp == last_input
	last_input = disp

	xy_index = (xy_index + 1) % 2
	var component: Vector2 = disp * XY_COMPONENTS[xy_index]
	if component == Vector2.ZERO:  # check the other component if zero
		component = disp * XY_COMPONENTS[(xy_index + 1) % 2]
	assert(component != Vector2.ZERO)
	component = component.normalized()

	if scan_area_body(component, false):
		return Vector2.ZERO

	var shift = Input.is_key_pressed(KEY_SHIFT)

	var para_list = [
		move_by_cell_inc,
		component,
		cell,
		{
			"last_disp": last_disp,
			"pressed": pressed,
			"shift": shift,
		},
	]
	player_request.emit(player, "move", para_list)

	return component


func move_by_cell_inc(cell_inc: Vector2, duration: float, tile_size: int = tile_size) -> void:
	cell += cell_inc
	last_disp = cell_inc
	_move_to(player.position + cell_inc * tile_size, duration)


func move_to_cell(cell_abs: Vector2, duration: float, tile_size: int = tile_size) -> void:
	cell = cell_abs
	last_disp = cell_abs - cell
	_move_to((cell_abs + Vector2.ONE / 2) * tile_size, duration)


func _move_to(target: Vector2, duration: float) -> void:
	assert(not moving)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(player, "position", target, duration).set_trans(Tween.TRANS_SINE)
	moving = true
	#$AnimationPlayer.play(dir)
	await tween.finished
	moving = false


func set_sprite_atlas(texture: Texture2D, atlas_cells, tile_size: int = tile_size):
	if atlas_cells is not Array:
		atlas_cells = [atlas_cells]
	enumerate(
		atlas_cells,
		func(i, atlas_cell):
			if atlas_cell is String:
				atlas_cell = str_to_var("Vector2" + atlas_cell)
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(
				atlas_cell * tile_size,
				Vector2(tile_size, tile_size),
			)
			add_sprite(atlas, var_to_str(i))
	)


func add_sprite(texture, name: String = "", scale: Vector2 = Vector2.ONE):
	var sprite = Sprite2D.new()
	sprite.texture = texture
	if name != "":
		sprite.name = name
	sprite.scale = scale
	add_child(sprite)


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


func enumerate(array: Array, fun: Callable):
	for i in range(len(array)):
		fun.call(i, array[i])
