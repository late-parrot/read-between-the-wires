class_name Main extends Control


signal completed
signal failed

var wire_scene = preload("res://scenes/wire.tscn")
var segment_font = preload("res://assets/3x5segmentnumber.ttf")

var solution = []
var rules = []:
	set(v):
		rules = v
		pages = []
		for i in range(0, rules.size(), 2):
			if i + 1 < rules.size():
				pages.append([rules[i], rules[i + 1]])
			else:
				pages.append([rules[i]])
var pages = []
var page:
	set(v):
		page = v
		if page < 0: page = pages.size()-1
		if page >= pages.size(): page = 0
		%Rule1.text = rule_to_str(pages[page][0]).to_upper()
		if len(pages[page]) > 1:
			%Rule2.text = rule_to_str(pages[page][1]).to_upper()
			%Rule2.visible = true
		else:
			%Rule2.visible = false
		%PageNumber.text = str(page+1)+"/"+str(pages.size())

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
	page = 0
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
		"before": return "Wire "+str(int(rule["first"])+1)+" must be cut before wire "+str(int(rule["second"])+1)
		"immediate": return "Wire "+str(int(rule["first"])+1)+" must be cut just before wire "+str(int(rule["second"])+1)
		"before_color": return "Wire "+str(int(rule["number"])+1)+" must be cut before any "+rule["color"]+" wires"
	return "Unknown rule"

func _on_next_pressed() -> void:
	if not Game.started: return
	page += 1

func _on_previous_pressed() -> void:
	if not Game.started: return
	page -= 1

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
