class_name Drag extends Control


@export var index: int

const DRAG_THRESHOLD = 4.0
var drag_start = Vector2.ZERO
var maybe_drag = false

@onready var dropped_in = get_parent()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT: return
		if event.pressed:
			drag_start = event.position
			maybe_drag = true
		else:
			maybe_drag = false
	elif event is InputEventMouseMotion and maybe_drag:
		if event.position.distance_to(drag_start) >= DRAG_THRESHOLD:
			maybe_drag = false
			var copy = duplicate()
			copy.tree_exited.connect(make_visible)
			modulate = Color(0,0,0,0)
			force_drag(self, copy)

func make_visible() -> void:
	modulate = Color(1,1,1)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return dropped_in._can_drop_data(at_position, data)

func _drop_data(at_position: Vector2, data: Variant) -> void:
	dropped_in._drop_data(at_position, data)
