extends RichTextLabel


signal set_as_wrong

var wrong = false:
	set(v):
		if v:
			emit_signal("set_as_wrong")
		wrong = v
		$Wrong.modulate = Color.WHITE if wrong else Color.TRANSPARENT

func _ready() -> void:
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	
func _on_mouse_entered() -> void:
	if not wrong:
		$Wrong.modulate = Color(1,1,1,0.5)

func _on_mouse_exited() -> void:
	$Wrong.modulate = Color.WHITE if wrong else Color.TRANSPARENT

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		wrong = not wrong
