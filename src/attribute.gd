extends Node
class_name Attribute
## Attribute

var domain: Domain
var data := {}


func _ready() -> void:
	Console.assertion(domain != null, "No domain available!")


func _process(_delta: float) -> void:
	pass
