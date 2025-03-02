extends CanvasLayer

var texts := {}


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func display(text_array: Array) -> void:
	var text = ""
	var head = text_array[0]
	for i in text_array:
		text += str(i)
	texts[head] = text

	text = ""
	for i in texts.values():
		text += i
		text += "\n"
	$Label.text = text
	print(text)
