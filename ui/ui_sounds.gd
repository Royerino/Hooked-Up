extends Node


@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var hover_sound: AudioStreamPlayer = $HoverSound


func play_click() -> void:
	click_sound.play()
	

func play_hover() -> void:
	hover_sound.play()
