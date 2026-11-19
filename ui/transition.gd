extends CanvasLayer


const DURATION := 0.35

@onready var panel: ColorRect = $Panel


func _ready() -> void:
	panel.position.x = -panel.size.x


func cover() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "position:x", 0.0, DURATION)
	tween.parallel().tween_method(Settings.set_music_fade, 1.0, 0.0, DURATION)
	await tween.finished


func uncover() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position:x", panel.size.x, DURATION)
	tween.parallel().tween_method(Settings.set_music_fade, 0.0, 1.0, DURATION)
	await tween.finished
	panel.position.x = -panel.size.x
