class_name Checkpoint extends Area2D


signal activated(checkpoint: Checkpoint)

var is_activated := false

@onready var respawn_point: Marker2D = $RespawnPoint
@onready var flag: Node2D = $Flag
@onready var fabric: AnimatedSprite2D = $Flag/Fabric
@onready var activate_sound: AudioStreamPlayer2D = $ActivateSound


func get_respawn_position() -> Vector2:
	return respawn_point.global_position


func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
		
	if not body is Ganchez:
		return
		
	is_activated = true
	activate_sound.play()
	flag.modulate.a = 1.0
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(fabric, "position:y", -19, 0.5)
	fabric.play("wave")
	activated.emit(self)
