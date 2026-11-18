extends CanvasLayer


signal restart_requested
signal main_menu_requested

const OPTIONS_MENU_SCENE := preload("res://ui/options_menu.tscn")

var previous_mouse_mode := Input.MOUSE_MODE_VISIBLE
var audio_bus_index := AudioServer.get_bus_index("Music")

@onready var continue_button: GameButton = $CenterContainer/Frame/PanelContainer/VBoxContainer/ContinueButton
@onready var options_button: GameButton = $CenterContainer/Frame/PanelContainer/VBoxContainer/OptionsButton
@onready var center_container: CenterContainer = $CenterContainer


func _on_continue_button_pressed() -> void:
	_handle_unpause()


func _on_reset_button_pressed() -> void:
	_handle_unpause()
	restart_requested.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()


func _exit_tree() -> void:
	AudioServer.set_bus_effect_enabled(audio_bus_index, 0, false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_handle_unpause()
		else:
			_handle_pause()
		get_viewport().set_input_as_handled()


func _handle_unpause() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = previous_mouse_mode
	AudioServer.set_bus_effect_enabled(audio_bus_index, 0, false)


func _handle_pause() -> void:
	visible = true
	get_tree().paused = true
	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	continue_button.grab_focus_silently()
	AudioServer.set_bus_effect_enabled(audio_bus_index, 0, true)


func _on_options_button_pressed() -> void:
	var options_menu := OPTIONS_MENU_SCENE.instantiate()
	add_child(options_menu)
	options_menu.closed.connect(_on_options_closed)
	center_container.visible = false


func _on_options_closed() -> void:
	center_container.visible = true
	options_button.grab_focus_silently()
