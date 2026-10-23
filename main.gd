extends Node


var current_level_index := 0
var current_level: Node
var start_screen: Control

@export var scenes: Array[PackedScene]
@export var start_screen_scene: PackedScene
@export var end_screen_scene: PackedScene


func _ready() -> void:
	start_screen = start_screen_scene.instantiate()
	add_child(start_screen)
	start_screen.started.connect(_on_start_screen_started)
	
	
func _on_start_screen_started() -> void:
	start_screen.queue_free()
	_load_level()


func _load_level() -> void:
	if current_level_index >= scenes.size():
		add_child(end_screen_scene.instantiate())
		return
		
	current_level = scenes[current_level_index].instantiate()
	add_child(current_level)
	current_level.finished.connect(_on_level_finished)


func _on_level_finished() -> void:
	current_level_index += 1
	_change_level.call_deferred()


func _change_level() -> void:
	remove_child(current_level)
	current_level.queue_free()
	_load_level()
