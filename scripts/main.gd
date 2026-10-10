class_name Main extends Control


signal completed
signal failed

var wire_scene = preload("res://scenes/wire.tscn")
var segment_font = preload("res://assets/3x5segmentnumber.ttf")

var solution = []
var rules = []:
	set(v):
		rules = v
		for i in range(1,6):
			var n = get_node("%Rule"+str(i))
			n.wrong = false
			if len(v) >= i:
				n.visible = true
				n.parse_bbcode(rule_to_str(v[i-1]))
			else:
				n.visible = false

var next = 0
var lost = false

var colors:
	set(v):
		colors = v
		delete_wires()
		for i in range(v.size()):
			var w = wire_scene.instantiate()
			w.index = i
			w.color = v[i]
			w.connect("cut", _on_wire_cut)
			%Wires.add_child(w)
			var l = Label.new()
			l.label_settings = LabelSettings.new()
			l.label_settings.font_size = 6
			l.text = str(i+1)
			%NumberLabels.add_child(l)

@onready var numbers = %NumberContainer.get_children()

func _ready() -> void:
	connect("completed", Game.completed)
	connect("failed", Game.failed)
	for i in range(1,6):
		var n = get_node("%Rule"+str(i))
		n.connect("set_as_wrong", _on_wrong_set)
	%SettingsButton.connect("pressed", %Settings.toggle)
	
func _process(_delta: float) -> void:
	%Parallax2D.autoscroll = Vector2.ZERO if Game.simple_background else Vector2(2,2)
	if Game.simple_background:
		%Parallax2D.scroll_offset = Vector2.ZERO
	if Game.ended: return
	var sec = %Timer.time_left
	%Minute.text = str(int(sec/60))
	%Second.text = str(int(sec)%60).lpad(2, "0")
	%Defused.text = str(Game.defused)+"/"+str(max(Game.puzzle-1, 0))+" in " \
		+str(int(ceilf(Game.total_time)/60.0))+":"+str(ceili(Game.total_time)%60).lpad(2, "0")

func start_puzzle(puzzle) -> void:
	if Game.ended: return
	lost = false
	%BombAnimationPlayer.play("drop")
	var cs = []
	for c in puzzle["colors"]:
		match c:
			"red": cs.append(Wire.WireColor.RED)
			"green": cs.append(Wire.WireColor.GREEN)
			"blue": cs.append(Wire.WireColor.BLUE)
			_: cs.append(Wire.WireColor.RED)
	colors = cs
	solution = puzzle["solution"]
	rules = puzzle["rules"]
	%Notes.clear()
	
	var num_wires = len(solution)
	for n in numbers:
		n.reparent(%NumberContainer)
		n.dropped_in = %NumberContainer
		n.visible = true
		if n.index >= num_wires:
			n.visible = false
	%NumberContainer.sort_children()
	
	next = solution[0]
	%Timer.start()

func delete_wires() -> void:
	for w in %Wires.get_children():
		w.queue_free()
	for l in %NumberLabels.get_children():
		l.queue_free()

func _on_wrong_set() -> void:
	for i in range(1,6):
		var n = get_node("%Rule"+str(i))
		n.wrong = false

func _on_wire_cut(wire: Wire) -> void:
	if Game.ended: return
	if wire.index == next:
		if solution.find(next)+1 >= len(solution):
			await wire.get_node("%Sprite").animation_finished
			win()
			return
		next = solution[solution.find(next)+1]
	else:
		await wire.get_node("%Sprite").animation_finished
		lose()

func _on_timer_timeout() -> void:
	lose()
	
func win() -> void:
	if Game.ended: return
	%DefuseSound.play()
	%BombAnimationPlayer.play("throw")
	await %BombAnimationPlayer.animation_finished
	emit_signal("completed", self)
	

func lose() -> void:
	if Game.ended or lost: return
	lost = true
	%ExplosionSound.play()
	%ExplosionAnimationPlayer.play("fade_out")
	%BombContainer.visible = false
	await %ExplosionAnimationPlayer.animation_finished
	%BombContainer.visible = true
	emit_signal("failed", self)

func rule_to_str(rule) -> String:
	match rule["type"]:
		"before": return "CUT WIRE [color=888]"+str(int(rule["first"])+1)+"[/color] BEFORE WIRE [color=888]"+str(int(rule["second"])+1)+"[/color]"
		"immediate": return "CUT WIRE [color=888]"+str(int(rule["first"])+1)+"[/color] JUST BEFORE WIRE [color=888]"+str(int(rule["second"])+1)+"[/color]"
		"before_color":
			var color_text = "[color="+{
				"red": "b45252",
				"green": "8ab060",
				"blue": "4b80ca"
			}[rule["color"]]+"]"+rule["color"].to_upper()+"[/color]"
			return "CUT WIRE [color=888]"+str(int(rule["number"])+1)+"[/color] BEFORE ANY "+color_text+" WIRES"
	return "Unknown rule"

func end():
	%BombContainer.queue_free()
	%FinalScore.text = str(Game.defused)+" out of "+str(Game.total_puzzles)
	var m = int(ceilf(Game.total_time)/60.0)
	var s = ceili(Game.total_time)%60
	%FinalTime.text = str(m)+" "+("minute" if m==1 else "minutes")+" and "+str(s)+" "+("second" if s==1 else "seconds")
	%Table.texture = load("res://assets/textures/table-full.png")
	%CreditsContainer.visible = true
	
	%EndAnimationPlayer.play("show_credits")
	await %EndAnimationPlayer.animation_finished
	%RulesContainer.queue_free()
	%NotesContainer.queue_free()
	%ScoreContainer.queue_free()

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_done_button_pressed() -> void:
	%TutorialContainer.queue_free()
	Game.started = true
	start_puzzle(Game.get_puzzle(self))

func _on_retry_pressed() -> void:
	%FadeIn.play("fade_out")
	await %FadeIn.animation_finished
	Game.reset()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_to_title_pressed() -> void:
	%FadeIn.play("fade_out")
	await %FadeIn.animation_finished
	get_tree().change_scene_to_file("res://scenes/title.tscn")
