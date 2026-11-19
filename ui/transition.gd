extends CanvasLayer


const DURATION := 0.35

@onready var panel: ColorRect = $Panel


func _ready() -> void:
	panel.position.x = -panel.size.x


func cover() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.tween_property(panel, "position:x", 0.0, DURATION).finished


func uncover() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.tween_property(panel, "position:x", panel.size.x, DURATION).finished
	panel.position.x = -panel.size.x
