extends Node


func _ready() -> void:
	Console.log("Main script is executing...")

	$Domain.add_attr($Player/Attribute)
	$Domain.del_attr($Player/Attribute)
	$Domain.add_attr($Player/Attribute)
	$Domain.del_attr($Player/Attribute)


func _process(_delta: float) -> void:
	pass
