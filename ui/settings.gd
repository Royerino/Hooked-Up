extends Node


const SETTINGS_PATH := "user://settings.cfg"
const MUSIC_BASE_DB := -6.0

var music_volume := 1.0
var sfx_volume := 1.0
var camera_follows_mouse := true


func _ready() -> void:
	load_settings()
	apply_volumes()


func save_settings() -> void:
	var config := ConfigFile.new()
	
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("camera", "follows_mouse", camera_follows_mouse)
	
	config.save(SETTINGS_PATH)


func load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	
	if error != OK:
		return

	music_volume = config.get_value("audio", "music", music_volume)
	sfx_volume = config.get_value("audio", "sfx", sfx_volume)
	camera_follows_mouse = config.get_value("camera", "follows_mouse", camera_follows_mouse)


func apply_volumes() -> void:
	var music_bus_index := AudioServer.get_bus_index("Music")
	var sfx_bus_index := AudioServer.get_bus_index("SFX")
	
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(music_volume) + MUSIC_BASE_DB)
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(sfx_volume))
