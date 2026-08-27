extends Node


var volume = 1.0:
	set(v):
		var idx := AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_linear(idx, v)
		volume = v
		save_settings()
var music_volume = 1.0:
	set(v):
		var idx := AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_linear(idx, v)
		music_volume = v
		save_settings()
var sfx_volume = 1.0:
	set(v):
		var idx := AudioServer.get_bus_index("SFX")
		AudioServer.set_bus_volume_linear(idx, v)
		sfx_volume = v
		save_settings()
var simple_background = false:
	set(v):
		simple_background = v
		save_settings()

var all_puzzles = JSON.parse_string(FileAccess.get_file_as_string("res://resources/puzzles.json"))
var num_puzzles = {4: 5, 5: 5}
var total_puzzles: int:
	get: return num_puzzles.values().reduce(func(a,b):return a+b)
var puzzles = []
var puzzle = 0
var defused = 0
var total_time = 0.0
var started = false
var ended = false

func _ready() -> void:
	load_settings()
	var s = []
	for k in num_puzzles.keys():
		for i in range(num_puzzles[k]):
			var p = all_puzzles[str(k)].pick_random()
			while p["solution"] == s:
				p = all_puzzles[str(k)].pick_random()
			s = p["solution"]
			puzzles.append(p)
			all_puzzles[str(k)].erase(p)

func reset() -> void:
	puzzles = []
	puzzle = 0
	defused = 0
	total_time = 0.0
	started = false
	ended = false
	_ready()

func _process(delta: float) -> void:
	if started and not ended:
		total_time += delta

func get_puzzle(main):
	if puzzle >= len(puzzles):
		end(main)
		return
	puzzle += 1
	return puzzles[puzzle-1]

func completed(main) -> void:
	var p = get_puzzle(main)
	if not ended:
		main.start_puzzle(p)
	defused += 1

func failed(main) -> void:
	var p = get_puzzle(main)
	if not ended:
		main.start_puzzle(p)

func end(main) -> void:
	ended = true
	main.end()

func save_settings() -> void:
	var save_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	var json_string = JSON.stringify({
		"volume": volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"simple_background": simple_background
	})
	save_file.store_string(json_string)

func load_settings() -> void:
	if not FileAccess.file_exists("user://settings.json"):
		return
	var json = JSON.parse_string(FileAccess.get_file_as_string("user://settings.json"))
	volume = json["volume"]
	music_volume = json["music_volume"]
	sfx_volume = json["sfx_volume"]
	simple_background = json["simple_background"]
