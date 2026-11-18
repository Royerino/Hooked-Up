extends Control


signal new_game_requested

@onready var new_game_button: GameButton = $CenterContainer/VBoxContainer/Buttons/NewGameButton


func _ready() -> void:
	new_game_button.grab_focus_silently()


func _on_new_game_button_pressed() -> void:
	new_game_requested.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
