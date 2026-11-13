extends Control


func _ready() -> void:
	Game.game_mode = Game.GameMode.CLASSIC
	Game.hard_mode = false

func _on_tutorial_pressed() -> void:
	%TutorialDescription.visible = true
	%ClassicDescription.visible = false
	%EndlessDescription.visible = false
	Game.game_mode = Game.GameMode.TUTORIAL

func _on_classic_pressed() -> void:
	%TutorialDescription.visible = false
	%ClassicDescription.visible = true
	%EndlessDescription.visible = false
	Game.game_mode = Game.GameMode.CLASSIC

func _on_endless_pressed() -> void:
	%TutorialDescription.visible = false
	%ClassicDescription.visible = false
	%EndlessDescription.visible = true
	Game.game_mode = Game.GameMode.ENDLESS

func _on_hard_mode_toggled(toggled_on: bool) -> void:
	Game.hard_mode = toggled_on

func _on_back_pressed() -> void:
	%FadeOut.play("fade_out")
	await %FadeOut.animation_finished
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_play_pressed() -> void:
	%FadeOut.play("fade_out")
	await %FadeOut.animation_finished
	if Game.game_mode == Game.GameMode.TUTORIAL:
		get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
