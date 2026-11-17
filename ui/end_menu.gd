extends Control


signal main_menu_requested

@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/Buttons/MainMenuButton


func _ready() -> void:
	main_menu_button.grab_focus()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	main_menu_requested.emit()
