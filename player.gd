extends Area2D
## A 2D character that moves in a grid pattern.
##
## Inspired: https://kidscancode.org/godot_recipes/4.x/2d/grid_movement/index.html
## Assisted by deepseek.

@export var tiles_per_second: float = 20
@export var shift_modifier: float = 0.3
var tile_size: int = 16
var speed: float = tile_size * tiles_per_second
var current_speed: float
var tween_duration: float
var half_tile = Vector2.ONE * tile_size / 2
var real_position: Vector2
var inputs: Dictionary = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up-left": (Vector2.UP + Vector2.LEFT).normalized(),
	"up-right": (Vector2.UP + Vector2.RIGHT).normalized(),
	"down-left": (Vector2.DOWN + Vector2.LEFT).normalized(),
	"down-right": (Vector2.DOWN + Vector2.RIGHT).normalized(),
}
#var moving: bool = false

@onready var ray: RayCast2D = $RayCast2D


func _ready() -> void:
	position = snapped_position()


func _process(delta: float) -> void:
	#if moving:
	#	return
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = speed * shift_modifier
	else:
		current_speed = speed
	tween_duration = tile_size / current_speed
	var displacement = Vector2.ZERO
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			displacement += inputs[dir]
	displacement = displacement.normalized()
	for vector2 in [Vector2(displacement.x, 0), Vector2(0, displacement.y)]:
		vector2 *= current_speed * delta
		position = real_position
		ray.target_position = vector2
		ray.force_raycast_update()
		if !ray.is_colliding():
			real_position += vector2
	if snapped_position() != position:
		move(snapped_position())


func snapped_position() -> Vector2:
	return (real_position - half_tile).snapped(Vector2.ONE * tile_size) + half_tile


func get_grid_position() -> Vector2:
	return (real_position - half_tile).snapped(Vector2.ONE * tile_size) / tile_size


func set_grid_position(grid_position: Vector2) -> void:
	real_position = grid_position * tile_size + half_tile


func move(target_position: Vector2) -> void:
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", target_position, tween_duration)
	#moving = true
	#$AnimationPlayer.play(dir)
	#await tween.finished
	#moving = false
