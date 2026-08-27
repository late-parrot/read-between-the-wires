extends TextEdit

@export var uppercase: bool
@export var focus_shortcut: Shortcut
@export var max_chars: int

var last_caret_line: int = 0
var last_caret_col: int = 0
var last_text: String = ""

func _on_text_changed() -> void:
	if max_chars > 0 and len(text) > max_chars:
		text = last_text
		set_caret_line(last_caret_line)
		set_caret_column(last_caret_col)
	last_caret_line = get_caret_line()
	last_caret_col = get_caret_column()
	if uppercase:
		text = text.to_upper()
	set_caret_line(last_caret_line)
	set_caret_column(last_caret_col)
	last_text = text

func _on_caret_changed() -> void:
	last_caret_line = get_caret_line()
	last_caret_col = get_caret_column()

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0), size).has_point(evLocal.position):
			release_focus()
	elif focus_shortcut and focus_shortcut.matches_event(event) and event.is_pressed() and not event.is_echo():
		if has_focus():
			release_focus()
		else:
			grab_focus()
		get_viewport().set_input_as_handled()
