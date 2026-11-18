class_name GameButton extends Button


var silent_focus := false


func grab_focus_silently() -> void:
	silent_focus = true
	grab_focus()


func _on_pressed() -> void:
	UiSounds.play_click()


func _on_focus_entered() -> void:
	if silent_focus:
		silent_focus = false
		return
	UiSounds.play_hover()


func _on_mouse_entered() -> void:
	grab_focus()
