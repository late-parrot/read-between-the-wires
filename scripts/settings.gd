extends Control


func _ready():
	%Master.value = Game.volume
	%Music.value = Game.music_volume
	%SFX.value = Game.sfx_volume
	%SimpleBackground.button_pressed = Game.simple_background

func _process(_delta: float) -> void:
	%Parallax2D.autoscroll = Vector2.ZERO if Game.simple_background else Vector2(2,2)
	if Game.simple_background:
		%Parallax2D.scroll_offset = Vector2.ZERO

func _on_master_value_changed(value: float):
	Game.volume = value

func _on_music_value_changed(value: float):
	Game.music_volume = value

func _on_sfx_value_changed(value: float):
	Game.sfx_volume = value

func _on_simple_background_toggled(toggled_on: bool) -> void:
	Game.simple_background = toggled_on

func toggle() -> void:
	visible = not visible
	mouse_filter = MOUSE_FILTER_STOP if visible else MOUSE_FILTER_IGNORE
	get_tree().paused = visible

func _on_close_pressed() -> void:
	toggle()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("settings"):
		toggle()

func _on_quit_pressed() -> void:
	get_tree().quit()
