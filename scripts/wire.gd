class_name Wire extends TextureButton


enum WireColor {
	RED, GREEN, BLUE
}

var frames = {
	WireColor.RED: preload("res://resources/wires/red.tres"),
	WireColor.GREEN: preload("res://resources/wires/green.tres"),
	WireColor.BLUE: preload("res://resources/wires/blue.tres")
}

signal cut
var index = 0
var color = WireColor.RED:
	set(v):
		color = v
		%Sprite.sprite_frames = frames[v]

var is_cut = false

func _on_pressed() -> void:
	if not is_cut:
		%Sprite.play("cut")
		%CutSound.play()
		emit_signal("cut", self)
		is_cut = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(str(index+1)):
		_on_pressed()
