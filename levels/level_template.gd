extends Node2D


const RESPAWN_TIME := 0.3

var is_finished := false
var is_respawning := false

@onready var player: CharacterBody2D = $PlayZone/Ganchez
@onready var respawn_point: Marker2D = $PlayZone/Respawn
@onready var zone_shape: CollisionShape2D = $PlayZone/CollisionShape2D


func _ready() -> void:
	_place_player()
	var shape := zone_shape.shape as RectangleShape2D
	var size: Vector2 = shape.size * zone_shape.global_scale
	var rect := Rect2(zone_shape.global_position - size / 2.0, size)
	player.set_camera_limits(rect)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		_restart_level()


func _restart_level() -> void:
	if is_finished or is_respawning:
		return
	_place_player()


func _place_player() -> void:
	player.respawn_at(respawn_point.global_position)


func _kill_player() -> void:
	is_respawning = true
	player.set_controllable(false)
	# TODO: partículas + VFX + sonido de muerte (en el nivel, no en el jugador).
	await get_tree().create_timer(RESPAWN_TIME).timeout
	_place_player()
	is_respawning = false


func _on_play_zone_body_exited(body: Node2D) -> void:
	if body != player or is_finished or is_respawning:
		return
	_kill_player()
