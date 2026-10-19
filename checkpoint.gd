class_name Checkpoint extends Area2D


signal activated(checkpoint: Checkpoint)

var is_activated := false

@onready var respawn_point: Marker2D = $RespawnPoint


func get_respawn_position() -> Vector2:
	return respawn_point.global_position


func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
		
	if not body is Ganchez:
		return
		
	is_activated = true
	activated.emit(self)
