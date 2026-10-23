extends Control


@onready var exit_prompt: HBoxContainer = $MarginContainer/HBoxContainer


func _ready() -> void:
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(exit_prompt, "modulate:a", 0.0, 1.0)
	tween.tween_property(exit_prompt, "modulate:a", 1.0, 1.0)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
