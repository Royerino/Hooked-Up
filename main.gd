extends Node


var current_level_index := 0
var current_level: Node
var main_menu: Control
var end_menu: Control
var is_transitioning := false

@export var scenes: Array[PackedScene]
@export var main_menu_scene: PackedScene
@export var end_screen_scene: PackedScene


func _ready() -> void:
	_show_main_menu()


func _transition(change: Callable) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	await Transition.cover()
	change.call()
	Transition.uncover()
	is_transitioning = false


func _show_main_menu() -> void:
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	main_menu.new_game_requested.connect(_on_main_menu_new_game_requested)

	
func _on_main_menu_new_game_requested() -> void:
	_transition(func():
		main_menu.queue_free()
		_load_level()
	)


func _load_level() -> void:
	if current_level_index >= scenes.size():
		end_menu = end_screen_scene.instantiate()
		add_child(end_menu)
		end_menu.main_menu_requested.connect(_on_end_screen_main_menu_requested)
		return
		
	current_level = scenes[current_level_index].instantiate()
	add_child(current_level)
	current_level.finished.connect(_on_level_finished)
	current_level.main_menu_requested.connect(_on_level_main_menu_requested)


func _on_level_finished() -> void:
	current_level_index += 1
	_change_level.call_deferred()


func _change_level() -> void:
	_transition(func():
		remove_child(current_level)
		current_level.queue_free()
		_load_level()
	)


func _on_level_main_menu_requested() -> void:
	_return_to_main_menu.call_deferred()


func _return_to_main_menu() -> void:
	_transition(func():
		get_tree().paused = false
		current_level.is_finished = true
		remove_child(current_level)
		current_level.queue_free()
		current_level_index = 0
		_show_main_menu()
	)


func _on_end_screen_main_menu_requested() -> void:
	_transition(func():
		end_menu.queue_free()
		current_level_index = 0
		_show_main_menu()
	)
