extends Node
class_name Console
## Error handling system
##
## Credits:[br]
## - Assisted by deepseek.
##
## @experimental

static var console := ULog.new("console")


static func _static_init() -> void:
	console.add_error("ERROR", UError.Severity.ERROR, Error.FAILED, "Error message.")
	console.add_error("WARN", UError.Severity.WARN, Error.OK, "Warn message.")
	console.add_error("INFO", UError.Severity.INFO, Error.OK, "Info message.")


static func assertion(condition: bool, message := "") -> void:
	if condition:
		return
	Console.display("ERROR", message)


static func error(message := "") -> void:
	Console.display("ERROR", message)


static func warn(message := "") -> void:
	Console.display("WARN", message)


static func info(message := "") -> void:
	Console.display("INFO", message)


static func log(message := "") -> void:
	Console.display("INFO", message)


static func display(name: String, message := "", ulog := console) -> void:
	var error := ulog.get_error(name)
	if not message:
		error.display()
		return
	var default_message: String = error.user_format.get_or_add("message", "{message}")
	error.user_format["message"] = message
	error.display()
	error.user_format["message"] = default_message


class ULog:
	var _name: String

	var level := UError.Severity.INFO

	var errors := {}  # TODO: use errors in UError

	static var s_not_implemented_error := UError.new(
		"NOT_IMPLEMENTED", UError.Severity.ERROR, Error.FAILED, UError.s_internal_error_text
	)
	static var s_not_implemented_warn := UError.new(
		"NOT_IMPLEMENTED", UError.Severity.WARN, Error.OK, UError.s_internal_warn_text
	)

	func _init(name: String) -> void:
		_name = name

	func get_error(name: String) -> UError:
		if errors.has(name):
			return errors[name]
		push_warning(UError.s_internal_warn_text)
		return s_not_implemented_warn

	func add_error(name: String, severity: UError.Severity, type: Error, message: String) -> void:
		var error := UError.new(name, severity, type, message)
		error.user_format["head"] = _name + ": "
		errors[name] = error

	func assertion(condition: bool, name: String) -> void:
		if condition:
			return
		display(name)

	func display(name: String) -> void:
		var error := get_error(name)
		if error._severity < level:
			return
		error.display()


class UError:
	# id
	static var s_code := 0
	static var s_codes := []
	var _code: int

	# info
	var _name: String
	var _severity: Severity
	enum Severity { TRACE, DEBUG, INFO, WARN, ERROR, FATAL }
	var _type: Error
	var _message: String

	# time
	var _time: String

	# format
	var format_text := "{head}{time} {severity} {name}<{code}> [{type}] {message}{tail}"
	var user_format: Dictionary = {"head": "", "tail": ""}
	static var s_internal_error_text := "Error handling system failed!"
	var internal_error_text := s_internal_error_text
	static var s_internal_warn_text := "Error handling system used improperly!"
	var internal_warn_text := s_internal_warn_text

	func assertion(condition: bool) -> void:
		if condition:
			return
		display()

	func display() -> void:
		match _severity:
			Severity.TRACE:
				print(_to_string())
			Severity.DEBUG:
				print(_to_string())
			Severity.INFO:
				print(_to_string())
			Severity.WARN:
				push_warning(_to_string())
			Severity.ERROR:
				push_error(_to_string())
			Severity.FATAL:
				printerr(_to_string())

	func _init(name: String, severity: Severity, type: Error, message: String) -> void:
		_code = s_code
		_name = name
		_severity = severity
		_type = type
		_message = message
		_time = Time.get_time_string_from_system()
		s_code += 1
		s_codes.append(self)

	func _error_dict() -> Dictionary:
		return {
			"code": _code,
			"name": _name,
			"severity": _severity_string(),
			"type": error_string(_type),
			"message": _message,
			"time": _time,
		}

	func _to_string() -> String:
		return format_text.format(user_format).format(_error_dict())

	func _severity_string() -> String:
		match _severity:
			Severity.TRACE:
				return "TRACE"
			Severity.DEBUG:
				return "DEBUG"
			Severity.INFO:
				return "INFO"
			Severity.WARN:
				return "WARN"
			Severity.ERROR:
				return "ERROR"
			Severity.FATAL:
				return "FATAL"
		push_error(s_internal_error_text)
		return "NOT_IMPLEMENTED"
