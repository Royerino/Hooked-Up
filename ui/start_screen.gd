extends Control


signal started

var game_started := false

@onready var prompt: Label = $CenterContainer/VBoxContainer/Prompt


func _ready() -> void:
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(prompt, "modulate:a", 0.0, 1.0)
	tween.tween_property(prompt, "modulate:a", 1.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if game_started:
		return
		
	var is_valid_input := event is InputEventKey
	if is_valid_input and event.is_pressed() and not event.is_echo():
		game_started = true
		get_viewport().set_input_as_handled()
		started.emit()
