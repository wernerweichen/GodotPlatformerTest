extends Node

const SFX_BUS: String = "SFX"
const MUSIC_BUS: String = "Music"
const SFX_POOL_SIZE: int = 8

var _music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_streams: Dictionary = {}
var _music_streams: Dictionary = {}
var _current_music_key: String = ""

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = MUSIC_BUS
	add_child(_music_player)
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		_sfx_pool.append(player)
	_load_streams()

func _load_streams() -> void:
	_load_dir("res://assets/audio/sfx/", ".wav", _sfx_streams)
	_load_dir("res://assets/audio/music/", ".ogg", _music_streams)

func _load_dir(path: String, ext: String, target: Dictionary) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(ext):
			target[file_name.get_basename()] = load(path + file_name)
		file_name = dir.get_next()

# Play a one-shot sound effect by filename key (without extension).
func play_sfx(key: String) -> void:
	if not _sfx_streams.has(key):
		push_warning("AudioManager: SFX not found: %s" % key)
		return
	for player: AudioStreamPlayer in _sfx_pool:
		if not player.playing:
			player.stream = _sfx_streams[key]
			player.play()
			return
	_sfx_pool[0].stream = _sfx_streams[key]
	_sfx_pool[0].play()

# Start a music track by filename key (without extension). No-ops if already playing.
func play_music(key: String) -> void:
	if key == _current_music_key and _music_player.playing:
		return
	if not _music_streams.has(key):
		push_warning("AudioManager: Music not found: %s" % key)
		return
	_current_music_key = key
	_music_player.stream = _music_streams[key]
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()
	_current_music_key = ""

func set_sfx_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), linear_to_db(clampf(linear, 0.0, 1.0)))

func set_music_volume(linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), linear_to_db(clampf(linear, 0.0, 1.0)))
