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
			Log.s_display(Log.ErrorCode.CODING_LOGIC, "Domain already exist!")
			return
		else:
			Log.s_display(Log.ErrorCode.INFO, "Domain already exist!")

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
				Log.s_display(Log.ErrorCode.USER, 'Wrong parameter for rule["init_override"]!')
	else:
		data[attr] = {}

	attr.domain = self


func del_attr(attr: Attribute) -> void:
	# not registered
	if attr.domain != self:
		if rule["check_del"]:
			Log.s_display(Log.ErrorCode.CODING_LOGIC, "Domain does not exist!")
			return
		else:
			Log.s_display(Log.ErrorCode.INFO, "Domain does not exist!")

	# logout policy
	Log.s_assert(data.has(attr), Log.ErrorCode.CODING_LOGIC, "Attribute dose not exist!")
	match rule["del_override"]:
		true:
			data.erase(attr)
			data[attr] = {}
		"partial":
			pass
		false:
			pass
		_:
			Log.s_display(Log.ErrorCode.USER, 'Wrong parameter for rule["del_override"]!')

	attr.domain = null
