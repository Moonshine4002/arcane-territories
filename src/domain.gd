extends Node
class_name Domain
## Domain

var rule := {
	"check_init": true,
	"init_override": "partial",
	"check_del": true,
	"del_override": false,
}
var data := {}


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func add_attr(attr: Attribute) -> void:
	# already registered
	if attr.domain == self:
		if rule["check_init"]:
			Console.error("Domain already exist!")
			return
		else:
			Console.warn("Domain already exist!")

	# sign in policy
	if data.has(attr):
		match rule["init_override"]:
			true:
				data.erase(attr)
				data[attr] = {}
			"partial":
				pass
			false:
				pass
			_:
				Console.error('Wrong parameter for rule["init_override"]!')
	else:
		data[attr] = {}

	attr.domain = self


func del_attr(attr: Attribute) -> void:
	# not registered
	if attr.domain != self:
		if rule["check_del"]:
			Console.error("Domain does not exist!")
			return
		else:
			Console.warn("Domain does not exist!")

	# logout policy
	Console.assertion(data.has(attr), "Attribute dose not exist!")
	match rule["del_override"]:
		true:
			data.erase(attr)
			data[attr] = {}
		"partial":
			pass
		false:
			pass
		_:
			Console.error('Wrong parameter for rule["del_override"]!')

	attr.domain = null
