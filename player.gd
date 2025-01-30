extends Area2D
## A 2D character that moves in a grid pattern.
##
## Inspired: https://kidscancode.org/godot_recipes/4.x/2d/grid_movement/index.html
## Assisted by deepseek.

@export var tile_size: int = 16
var cell_position: Vector2

@export var seconds_per_tile: float = 0.05
@export var shift_modifier: float = 3
var moving: bool = false
var tween_duration: float

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

@onready var ray: RayCast2D = $RayCast2D


func _ready() -> void:
	set_cell_position(cell_position)


func _process(delta: float) -> void:
	if moving:
		return
	if Input.is_key_pressed(KEY_SHIFT):
		tween_duration = seconds_per_tile * shift_modifier
	else:
		tween_duration = seconds_per_tile

	var displacement = Vector2.ZERO
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			displacement += inputs[dir]

	var displacement_components = [
		Vector2(displacement.x, 0).normalized(),
		Vector2(0, displacement.y).normalized(),
	]
	displacement_components.shuffle()
	for component in displacement_components:
		if component == Vector2.ZERO:
			continue
		ray.target_position = component * tile_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			set_cell_position(cell_position + component)
			break


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
