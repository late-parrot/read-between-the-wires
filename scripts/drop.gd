class_name Drop extends Control


@export var max_children: int = 2
@export var container: Control
@export var sorted: bool = false

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if !data is Drag: return false
	return container.get_child_count() < max_children or container.get_child(-1).index == data.index

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if !data is Drag: return
	UiSfx.play_hover()
	var drag_data := data as Drag
	drag_data.reparent(container)
	drag_data.dropped_in = self
	drag_data.visible = true
	if sorted:
		sort_children()

func sort_children() -> void:
	var children = get_children()
	children.sort_custom(
		func(a: Node, b: Node):
			if a is not Drag: return true
			if b is not Drag: return false
			return a.index < b.index
	)
	for node in get_children():
		remove_child(node)
	for node in children:
		add_child(node)
