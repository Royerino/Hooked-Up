extends CanvasLayer


signal restart_requested
signal main_menu_requested

var previous_mouse_mode := Input.MOUSE_MODE_VISIBLE

@onready var cont: Button = $CenterContainer/Frame/PanelContainer/VBoxContainer/ContinueButton


func _on_continue_button_pressed() -> void:
	_handle_unpause()


func _on_reset_button_pressed() -> void:
	_handle_unpause()
	restart_requested.emit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()


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


func _handle_pause() -> void:
	visible = true
	get_tree().paused = true
	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	cont.grab_focus()
