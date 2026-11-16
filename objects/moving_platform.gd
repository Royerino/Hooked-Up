@tool
extends Node2D


@export var travel_distance := 200.0:
	set(value):
		travel_distance = value
		if is_node_ready():
			_update_rail()
@export var move_vertical := false:
	set(value):
		move_vertical = value
		if is_node_ready():
			_update_rail()
@export var duration := 1.5

@onready var animation_player: AnimationPlayer = $AnimatableBody2D/AnimationPlayer
@onready var rail: Line2D = $Rail


func _ready() -> void:
	var destination := _update_rail()
	
	if Engine.is_editor_hint():
		return
		
	var animation := Animation.new()

	var track_index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, NodePath(".:position"))
	var first_key := animation.track_insert_key(track_index, 0, Vector2.ZERO)

	var second_key := animation.track_insert_key(track_index, duration, destination)
	
	animation.track_set_key_transition(track_index, first_key, -2)
	animation.track_set_key_transition(track_index, second_key, -2)
	
	animation.length = duration
	animation.loop_mode = Animation.LOOP_PINGPONG

	var library := AnimationLibrary.new()
	library.add_animation("movement", animation)
	animation_player.add_animation_library("", library)
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	animation_player.play("movement")


func _update_rail() -> Vector2:
	var destination := Vector2.ZERO
	if move_vertical:
		destination.y = travel_distance
	else:
		destination.x = travel_distance
	rail.points = PackedVector2Array([Vector2.ZERO, destination])
	return destination
