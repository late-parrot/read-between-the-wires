class_name Tutorial extends Main

var dialogue_tween: Tween

var tutorial_steps = JSON.parse_string(FileAccess.get_file_as_string("res://resources/tutorial.json"))
var puzzle
var step = 0:
	set(v):
		if v >= tutorial_steps.size():
			end()
		else:
			#while tutorial_steps[v].has("mobile") and tutorial_steps[v]["mobile"] != Game.mobile:
				#v += 1
			%Dialogue.parse_bbcode(tutorial_steps[v]["text"])
			%Dialogue.visible_characters = 0
			dialogue_tween = get_tree().create_tween()
			dialogue_tween.tween_property(%Dialogue, "visible_characters", 60, 2)
			%HintContainer.visible = false
			if tutorial_steps[v].has("defuse"):
				%Next.visible = false
				%Defuse.visible = true
				puzzle = tutorial_steps[v]["defuse"]
				if puzzle.has("hint"):
					%Hint.parse_bbcode(puzzle["hint"])
					%HintButton.visible = true
				else:
					%HintButton.visible = false
				start_puzzle(puzzle)
				await completed
				%Next.visible = true
				%Defuse.visible = false
			else:
				%Next.visible = true
				%Defuse.visible = false
				%HintButton.visible = false
				for i in range(1,6):
					var n = get_node("%Rule"+str(i))
					n.wrong = false
					n.parse_bbcode("")
		step = v

func _ready() -> void:
	tutorial = true
	%Dialogue.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	super._ready()
	tutorial_steps = tutorial_steps.filter(func(x): return not x.has("mobile") or x["mobile"] == Game.mobile)

func end():
	%FadeIn.play("fade_out")
	await %FadeIn.animation_finished
	Game.reset()
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_next_pressed() -> void:
	if dialogue_tween:
		dialogue_tween.kill()
		if %Dialogue.visible_ratio < 0.9:
			%Dialogue.visible_ratio = 1.0
			return
	step += 1

func _on_hint_button_pressed() -> void:
	%HintContainer.visible = not %HintContainer.visible

func _on_close_hint_pressed() -> void:
	%HintContainer.visible = false
