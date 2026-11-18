extends CanvasLayer


signal closed

@onready var music_slider: HSlider = $CenterContainer/Frame/PanelContainer/VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/Frame/PanelContainer/VBoxContainer/HBoxContainer2/SfxSlider
@onready var camera_check: CheckButton = $CenterContainer/Frame/PanelContainer/VBoxContainer/HBoxContainer3/CameraCheck
@onready var back_button: GameButton = $CenterContainer/Frame/PanelContainer/VBoxContainer/HBoxContainer4/BackButton


func _ready() -> void:
	music_slider.set_value_no_signal(Settings.music_volume)
	sfx_slider.set_value_no_signal(Settings.sfx_volume)
	camera_check.set_pressed_no_signal(Settings.camera_follows_mouse)
	back_button.grab_focus_silently()


func _close() -> void:
	Settings.save_settings()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_close()
		get_viewport().set_input_as_handled()


func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.apply_volumes()


func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.apply_volumes()


func _on_camera_check_toggled(toggled_on: bool) -> void:
	Settings.camera_follows_mouse = toggled_on


func _on_back_button_pressed() -> void:
	_close()
