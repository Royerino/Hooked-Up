extends Node


var current_level_index := 0
var current_level: Node

@export var scenes: Array[PackedScene]


func _ready() -> void:
	if scenes.is_empty():
		return
	_load_level()


func _load_level() -> void:
	current_level = scenes[current_level_index].instantiate()
	add_child(current_level)
	current_level.finished.connect(_on_level_finished)


func _on_level_finished() -> void:
	current_level.queue_free()
	current_level_index += 1
	if current_level_index < scenes.size():
		_load_level()
