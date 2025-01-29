extends Area2D
## A 2D character that moves in a grid pattern.
##
## Inspired: https://kidscancode.org/godot_recipes/4.x/2d/grid_movement/index.html

@export var tiles_per_second: int = 20
@export var shift_modifier: float = 0.3
var speed: int = 16 * tiles_per_second
var tween_duration: float = 1 / tiles_per_second * 20
var tile_size: int = 16
var real_position = Vector2.ZERO
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
#var moving: bool = false

@onready var ray: RayCast2D = $RayCast2D


func _ready() -> void:
	position = snapped_position()


func _process(delta: float) -> void:
	#if moving:
	#	return
	var current_speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = speed * shift_modifier
	else:
		current_speed = speed
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			ray.target_position = inputs[dir] * tile_size
			ray.force_raycast_update()
			if !ray.is_colliding():
				real_position += inputs[dir] * current_speed * delta
	if snapped_position() != position:
		move(snapped_position())


func snapped_position() -> Vector2:
	var half_tile = Vector2.ONE * tile_size / 2
	return (real_position - half_tile).snapped(Vector2.ONE * tile_size) + half_tile


func move(target_position: Vector2) -> void:
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", target_position, tween_duration)
	#moving = true
	#$AnimationPlayer.play(dir)
	#await tween.finished
	#moving = false
