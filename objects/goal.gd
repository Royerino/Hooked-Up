class_name Goal extends Area2D


signal reached


func _on_body_entered(body: Node2D) -> void:
	if not body is Ganchez:
		return
	reached.emit()
