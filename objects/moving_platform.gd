extends Node2D


@export var travel_distance := 200.0
@export var duration := 1.5
@export var move_vertical := false

@onready var animation_player: AnimationPlayer = $AnimatableBody2D/AnimationPlayer


func _ready() -> void:
	var animation := Animation.new()

	var track_index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, NodePath(".:position"))
	animation.track_insert_key(track_index, 0, Vector2.ZERO)

	var destination := Vector2.ZERO
	if move_vertical:
		destination.y = travel_distance
	else:
		destination.x = travel_distance
	animation.track_insert_key(track_index, duration, destination)
	
	animation.length = duration
	animation.loop_mode = Animation.LOOP_PINGPONG

	var library := AnimationLibrary.new()
	library.add_animation("movement", animation)
	animation_player.add_animation_library("", library)
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	animation_player.play("movement")
