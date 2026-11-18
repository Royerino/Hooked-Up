extends Control


signal new_game_requested

const OPTIONS_MENU_SCENE := preload("res://ui/options_menu.tscn")

@onready var new_game_button: GameButton = $CenterContainer/VBoxContainer/Buttons/NewGameButton
@onready var options_button: GameButton = $CenterContainer/VBoxContainer/Buttons/OptionsButton
@onready var center_container: CenterContainer = $CenterContainer


func _ready() -> void:
	new_game_button.grab_focus_silently()


func _on_new_game_button_pressed() -> void:
	new_game_requested.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	var options_menu := OPTIONS_MENU_SCENE.instantiate()
	add_child(options_menu)
	options_menu.closed.connect(_on_options_closed)
	center_container.visible = false


func _on_options_closed() -> void:
	center_container.visible = true
	options_button.grab_focus_silently()
