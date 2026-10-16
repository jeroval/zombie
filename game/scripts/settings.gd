extends RefCounted

const PATH := "user://settings.cfg"
const VERSION := 1
const DEFAULTS := {
	"master": 0.85,
	"music": 0.35,
	"sfx": 0.85,
	"voice": 0.90,
	"sensitivity": 1.0,
	"fov": 85.0,
	"shake": true,
	"fullscreen": false,
	"best_time": 0.0,
	"best_kills": 0,
}

static func load_file(path := PATH) -> Dictionary:
	var values := DEFAULTS.duplicate()
	var config := ConfigFile.new()
	if config.load(path) != OK or int(config.get_value("meta", "version", 0)) != VERSION:
		return values
	values.master = clampf(float(config.get_value("audio", "master", values.master)), 0, 1)
	values.music = clampf(float(config.get_value("audio", "music", values.music)), 0, 1)
	values.sfx = clampf(float(config.get_value("audio", "sfx", values.sfx)), 0, 1)
	values.voice = clampf(float(config.get_value("audio", "voice", values.voice)), 0, 1)
	values.sensitivity = clampf(float(config.get_value("controls", "sensitivity", values.sensitivity)), 0.35, 2.5)
	values.fov = clampf(float(config.get_value("video", "fov", values.fov)), 70, 105)
	values.shake = bool(config.get_value("video", "shake", values.shake))
	values.fullscreen = bool(config.get_value("video", "fullscreen", values.fullscreen))
	values.best_time = maxf(float(config.get_value("results", "best_time", values.best_time)), 0)
	values.best_kills = maxi(int(config.get_value("results", "best_kills", values.best_kills)), 0)
	return values

static func save_file(values: Dictionary, path := PATH) -> Error:
	var config := ConfigFile.new()
	config.set_value("meta", "version", VERSION)
	for key in ["master", "music", "sfx", "voice"]:
		config.set_value("audio", key, values[key])
	config.set_value("controls", "sensitivity", values.sensitivity)
	config.set_value("video", "fov", values.fov)
	config.set_value("video", "shake", values.shake)
	config.set_value("video", "fullscreen", values.fullscreen)
	config.set_value("results", "best_time", values.best_time)
	config.set_value("results", "best_kills", values.best_kills)
	return config.save(path)

static func record_result(values: Dictionary, elapsed: float, kills: int, won: bool) -> Dictionary:
	var updated := values.duplicate()
	updated.best_kills = maxi(int(updated.get("best_kills", 0)), kills)
	var previous := float(updated.get("best_time", 0))
	if won and (previous <= 0 or elapsed < previous):
		updated.best_time = elapsed
	return updated
