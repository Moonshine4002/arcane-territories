extends Node
class_name Attribute
## Attribute

var domain: Domain
var data := {}


func _ready() -> void:
	Log.s_assert(domain != null, Log.ErrorCode.INITIALIZATION, "No domain available!")


func _process(_delta: float) -> void:
	pass
