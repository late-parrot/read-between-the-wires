extends Control


func _ready() -> void:
	if Game.fade_title:
		%FadeOut.play("fade_in")
	else:
		%FadeOut.play("RESET")
		Game.fade_title = true

func _process(_delta: float) -> void:
	%Parallax2D.autoscroll = Vector2.ZERO if Game.simple_background else Vector2(2,2)
	if Game.simple_background:
		%Parallax2D.scroll_offset = Vector2.ZERO

func _on_play_pressed() -> void:
	%FadeOut.play("fade_out")
	await %FadeOut.animation_finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
