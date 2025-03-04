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
	OK,
}
const ERROR_SEVERITY := {
	ErrorCode.OK: Severity.TRACE,
}
const ERROR_TYPE := {
	ErrorCode.OK: "OK",
}

## Global severity
static var file_severity := Severity.TRACE
## Local severity
var node_severity := Severity.NOT_IMPLEMENTED


func display(code: ErrorCode, message: String) -> void:
	var err_dict := _make_error_dict(code, message, 2)
	var severity: Severity = err_dict["severity_code"]
	if node_severity == Severity.NOT_IMPLEMENTED:
		node_severity = file_severity
	if severity < node_severity:
		return
	_display_error(err_dict)


static func s_display(code: ErrorCode, message: String) -> void:
	var err_dict := _make_error_dict(code, message, 2)
	var severity: Severity = err_dict["severity_code"]
	if severity < file_severity:
		return
	_display_error(err_dict)


static func _make_error_dict(code: ErrorCode, message: String, traceback_level: int) -> Dictionary:
	var timestamp := Time.get_time_string_from_system()
	var severity_code: Severity = ERROR_SEVERITY.get(code, Severity.NOT_IMPLEMENTED)
	var severity: String
	if SEVERITY_MESSAGES.has(severity_code):
		severity = SEVERITY_MESSAGES[severity_code]
	else:
		severity = "NOT-IMPLEMENTED"
		severity_code = Severity.NOT_IMPLEMENTED
	var type: String
	if ERROR_TYPE.has(code):
		type = ERROR_TYPE[code]
	else:
		type = "NOT-IMPLEMENTED"
		severity_code = Severity.NOT_IMPLEMENTED
	var traceback := "traceback: <{source}>::{function}[{line}]".format(
		get_stack()[traceback_level]
	)
	return {
		"code": code,
		"timestamp": timestamp,
		"severity_code": severity_code,
		"severity": severity,
		"type": type,
		"message": message,
		"traceback": traceback,
	}


static func _make_error_str(
	err_dict: Dictionary,
	format_str := '<{code}> {timestamp} {severity} [{type}] "{message}" {traceback}'
) -> String:
	return format_str.format(err_dict)


static func _make_error_str_without_severity(err_dict: Dictionary) -> String:
	return _make_error_str(err_dict, '<{code}> {timestamp} [{type}] "{message}" {traceback}')


static func _display_error(err_dict: Dictionary) -> void:
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
			printerr(_make_error_str_without_severity(err_dict))
			push_error(_make_error_str_without_severity(err_dict))
		_:
			printerr("NOT-IMPLEMENTED: ", _make_error_str(err_dict))
			push_error("NOT-IMPLEMENTED: ", _make_error_str(err_dict))
