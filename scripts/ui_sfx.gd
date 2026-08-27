extends Node


var playback: AudioStreamPlaybackPolyphonic


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	add_child(player)

	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is Button:
		node.mouse_entered.connect(play_hover)
		node.pressed.connect(play_pressed)
	if node is HSlider:
		node.mouse_entered.connect(play_hover)

func play_hover() -> void:
	playback.play_stream(preload("res://assets/sfx/move.wav"))

func play_pressed() -> void:
	playback.play_stream(preload("res://assets/sfx/select.wav"))
