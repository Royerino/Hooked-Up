class_name Checkpoint extends Area2D


signal activated(checkpoint: Checkpoint)

var is_activated := false

@onready var respawn_point: Marker2D = $RespawnPoint

@export var texture_activated: Texture2D
@export var texture_not_activated: Texture2D


func _ready() -> void:
	$Sprite2D.texture = texture_not_activated
	$Sprite2D.global_position = $RespawnPoint.global_position


func get_respawn_position() -> Vector2:
	return respawn_point.global_position


func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
		
	if not body is Ganchez:
		return
		
	is_activated = true
	$Sprite2D.texture = texture_activated
	activated.emit(self)
