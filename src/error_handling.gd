extends Node
class_name Log
## Error handling system
##
## Credits:[br]
## - Assisted by deepseek.
##
## @experimental

enum Severity { TRACE, DEBUG, INFO, WARN, ERROR, FATAL, NOT_IMPLEMENTED }
const SEVERITY_MESSAGES := {
	Severity.TRACE: "TRACE",
	Severity.DEBUG: "DEBUG",
	Severity.INFO: "INFO",
	Severity.WARN: "WARN",
	Severity.ERROR: "ERROR",
	Severity.FATAL: "FATAL",
	Severity.NOT_IMPLEMENTED: "NOT-IMPLEMENTED",
}
enum ErrorCode {
	TRACE,
	DEBUG,
	INFO,
	WARN,
	ERROR,
	FATAL,
	OK,
	CODING_LOGIC,
	INITIALIZATION,
	USER,
}
const ERROR_SEVERITY := {
	ErrorCode.TRACE: Severity.TRACE,
	ErrorCode.DEBUG: Severity.DEBUG,
	ErrorCode.INFO: Severity.INFO,
	ErrorCode.WARN: Severity.WARN,
	ErrorCode.ERROR: Severity.ERROR,
	ErrorCode.FATAL: Severity.FATAL,
	ErrorCode.OK: Severity.TRACE,
	ErrorCode.CODING_LOGIC: Severity.ERROR,
	ErrorCode.INITIALIZATION: Severity.WARN,
	ErrorCode.USER: Severity.WARN,
}
const ERROR_TYPE := {
	ErrorCode.TRACE: "severity",
	ErrorCode.DEBUG: "severity",
	ErrorCode.INFO: "severity",
	ErrorCode.WARN: "severity",
	ErrorCode.ERROR: "severity",
	ErrorCode.FATAL: "severity",
	ErrorCode.OK: "status",
	ErrorCode.CODING_LOGIC: "logic",
	ErrorCode.INITIALIZATION: "logic",
	ErrorCode.USER: "user",
}

## Global severity
static var file_severity := Severity.TRACE
## Local severity
var node_severity := Severity.NOT_IMPLEMENTED


func assertion(
	condition: bool, code: ErrorCode, message: String, _silent := false, _stack_inc := 0
) -> void:
	if condition:
		return
	display(code, message, _silent, 1 + _stack_inc)


func display(code: ErrorCode, message: String, _silent := false, _stack_inc := 0) -> void:
	if node_severity == Severity.NOT_IMPLEMENTED:
		node_severity = file_severity
	s_display(code, message, _silent, node_severity, 1 + _stack_inc)


static func s_assert(
	condition: bool, code: ErrorCode, message: String, _silent := false, _stack_inc := 0
) -> void:
	if condition:
		return
	s_display(code, message, _silent, 1 + _stack_inc)


static func s_display(
	code: ErrorCode,
	message: String,
	_silent := false,
	_stack_inc := 0,
	_filter_severity := Severity.NOT_IMPLEMENTED
) -> void:
	if _silent or not OS.is_debug_build():
		return
	var err_dict := make_error_dict(code, message, 1 + _stack_inc)
	if _filter_severity == Severity.NOT_IMPLEMENTED:
		_filter_severity = file_severity
	var severity: Severity = err_dict["severity_code"]
	if severity < _filter_severity:
		return
	display_error_dict(err_dict)


static func make_error_dict(code: ErrorCode, message: String, _stack_inc: int = 0) -> Dictionary:
	var timestamp := Time.get_time_string_from_system()
	var severity_code: Severity = ERROR_SEVERITY.get(code, Severity.NOT_IMPLEMENTED)
	var severity: String
	if SEVERITY_MESSAGES.has(severity_code):
		severity = SEVERITY_MESSAGES[severity_code]
	else:
		severity = SEVERITY_MESSAGES[Severity.NOT_IMPLEMENTED]
		severity_code = Severity.NOT_IMPLEMENTED
	var type: String
	if ERROR_TYPE.has(code):
		type = ERROR_TYPE[code]
	else:
		type = SEVERITY_MESSAGES[Severity.NOT_IMPLEMENTED]
		severity_code = Severity.NOT_IMPLEMENTED
	var traceback := "traceback: <{source}>::{function}[{line}]".format(get_stack()[1 + _stack_inc])
	return {
		"code": code,
		"timestamp": timestamp,
		"severity_code": severity_code,
		"severity": severity,
		"type": type,
		"message": message,
		"traceback": traceback,
	}


static func display_error_dict(err_dict: Dictionary) -> void:
	var severity: Severity = err_dict["severity_code"]
	match severity:
		Severity.TRACE:
			print(_make_error_str(err_dict))
		Severity.DEBUG:
			print(_make_error_str(err_dict))
		Severity.INFO:
			print(_make_error_str(err_dict))
		Severity.WARN:
			push_warning(_make_error_str_without_severity(err_dict))
		Severity.ERROR:
			push_error(_make_error_str_without_severity(err_dict))
		Severity.FATAL:
			#printerr(_make_error_str_without_severity(err_dict))
			push_error(_make_error_str_without_severity(err_dict))
		Severity.NOT_IMPLEMENTED:
			var hint := SEVERITY_MESSAGES[Severity.NOT_IMPLEMENTED] + ": "
			#printerr(hint, _make_error_str_without_severity(err_dict))
			push_error(hint, _make_error_str_without_severity(err_dict))
		_:
			assert(false, "Error handling system breaks!")


static func _make_error_str_without_severity(err_dict: Dictionary) -> String:
	return _make_error_str(err_dict, '<{code}> {timestamp} [{type}] "{message}" {traceback}')


static func _make_error_str(
	err_dict: Dictionary,
	format_str := '<{code}> {timestamp} {severity} [{type}] "{message}" {traceback}'
) -> String:
	return format_str.format(err_dict)
