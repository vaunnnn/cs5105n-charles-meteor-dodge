extends Node
## Persistent players let one-shot sounds finish across scene changes.

var music: AudioStreamPlayer
var click: AudioStreamPlayer
var collision: AudioStreamPlayer

func _ready() -> void:
	music = _player("Music", load("res://assets/audio/space_loop.wav"), "Music", -8.0)
	var loop := music.stream as AudioStreamWAV
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_begin = 0
	loop.loop_end = roundi(loop.get_length() * loop.mix_rate)
	click = _player("Click", load("res://assets/audio/menu_click.wav"), "SFX", -5.0)
	click.max_polyphony = 4
	collision = _player("Collision", load("res://assets/audio/collision.wav"), "SFX", -2.0)

func _exit_tree() -> void:
	for player in [music, click, collision]:
		if is_instance_valid(player):
			player.stop()

func _player(node_name: String, stream: AudioStream, bus: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.stream = stream
	player.bus = bus
	player.volume_db = volume
	add_child(player)
	return player

func start_music() -> void:
	if not music.playing:
		music.play()

func stop_music() -> void:
	music.stop()

func play_click() -> void:
	click.play()

func play_collision() -> void:
	collision.play()
