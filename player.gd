extends Area2D
## A 2D character that moves in a grid pattern.
##
## Inspired: https://kidscancode.org/godot_recipes/4.x/2d/grid_movement/index.html
## Assisted by deepseek.

# position
@export var tile_size: int = 16
var cell_position: Vector2

# speed
@export var seconds_per_tile: float = 0.05
@export var shift_modifier: float = 3
var moving: bool = false
var tween_duration: float

# control
var inputs: Dictionary = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up-left": Vector2.UP + Vector2.LEFT,
	"up-right": Vector2.UP + Vector2.RIGHT,
	"down-left": Vector2.DOWN + Vector2.LEFT,
	"down-right": Vector2.DOWN + Vector2.RIGHT,
}
var xy_components = [
	Vector2(1, 0),
	Vector2(0, 1),
]

# collision
@onready var ray: RayCast2D = $RayCast2D

# perception
var target_position: Vector2 = Vector2(33, 0)
signal ray_cast_area(me, target)

# data
var data: Dictionary


func _ready() -> void:
	set_cell_position(cell_position)


func _process(delta: float) -> void:
	target_position = target_position.rotated(0.1)
	if scan_area(target_position):
		ray_cast_area.emit(self, ray.get_collider())


func control():
	if moving:
		return

	var displacement = Vector2.ZERO
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			displacement += inputs[dir]

	var xy_component = xy_components.pop_front()
	xy_components.append(xy_component)
	var component = xy_component * displacement
	if component == Vector2.ZERO:
		return
	component = component.normalized()

	if not scan_area_and_body(component * tile_size):
		set_cell_position(cell_position + component)


func scan_area(target_position) -> bool:
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	ray.target_position = target_position
	ray.force_raycast_update()
	if ray.get_collider() is TileMapLayer:
		return false
	if not ray.is_colliding():
		return false
	return true


func scan_area_and_body(target_position) -> bool:
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	ray.target_position = target_position
	ray.force_raycast_update()
	if not ray.is_colliding():
		return false
	return true


func get_cell_position() -> Vector2:
	return cell_position


func set_cell_position(cell: Vector2) -> void:
	cell_position = cell
	move((cell + Vector2.ONE / 2) * tile_size)


func move(target_position) -> void:
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", target_position, tween_duration)
	moving = true
	#$AnimationPlayer.play(dir)
	await tween.finished
	moving = false


func calculate_tween_duration(speed_modifier):
	if Input.is_key_pressed(KEY_SHIFT):
		tween_duration = seconds_per_tile * shift_modifier
	else:
		tween_duration = seconds_per_tile
	tween_duration /= speed_modifier
