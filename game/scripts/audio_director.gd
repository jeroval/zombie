extends Node

const SOUNDS := {
	"shot": preload("res://audio/generated/pistol_shot.wav"),
	"empty": preload("res://audio/generated/empty_click.wav"),
	"reload": preload("res://audio/generated/reload.wav"),
	"melee": preload("res://audio/generated/melee_swing.wav"),
	"hit": preload("res://audio/generated/hit_enemy.wav"),
	"hurt": preload("res://audio/generated/hurt.wav"),
	"pickup": preload("res://audio/generated/pickup.wav"),
	"radio": preload("res://audio/generated/radio_on.wav"),
	"extract": preload("res://audio/generated/extract.wav"),
}
const VOICES := {
	"intro": preload("res://audio/voice/intro.wav"),
	"defense": preload("res://audio/voice/defense.wav"),
	"extract": preload("res://audio/voice/extract.wav"),
	"victory": preload("res://audio/voice/victory.wav"),
}
const AMBIENCE = preload("res://audio/generated/empty_city_loop.wav")

var voice: AudioStreamPlayer
var music: AudioStreamPlayer
var events: Array[String] = []
var sfx_pool: Array[AudioStreamPlayer] = []
var pool_cursor := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	voice = AudioStreamPlayer.new()
	voice.bus = &"Voice"
	add_child(voice)
	music = AudioStreamPlayer.new()
	music.bus = &"Music"
	var loop: AudioStreamWAV = AMBIENCE.duplicate()
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_begin = 0
	loop.loop_end = roundi(loop.get_length() * loop.mix_rate)
	music.stream = loop
	add_child(music)
	if DisplayServer.get_name() != "headless":
		music.play()
	for index in range(12):
		var player := AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		sfx_pool.append(player)

func play_sfx(sound: String, volume_db := 0.0) -> void:
	if not SOUNDS.has(sound) or sfx_pool.is_empty():
		return
	events.append("sfx:" + sound)
	if events.size() > 64:
		events.pop_front()
	if DisplayServer.get_name() == "headless":
		return
	var player := sfx_pool[pool_cursor]
	pool_cursor = (pool_cursor + 1) % sfx_pool.size()
	player.stop()
	player.stream = SOUNDS[sound]
	player.volume_db = volume_db
	player.play()

func play_voice(line: String) -> void:
	if not VOICES.has(line):
		return
	events.append("voice:" + line)
	if events.size() > 64:
		events.pop_front()
	if DisplayServer.get_name() == "headless":
		return
	voice.stop()
	voice.stream = VOICES[line]
	voice.play()

func _exit_tree() -> void:
	shutdown()

func shutdown() -> void:
	for player in [voice, music] + sfx_pool:
		if not is_instance_valid(player):
			continue
		player.stop()
		player.stream = null
	sfx_pool.clear()
