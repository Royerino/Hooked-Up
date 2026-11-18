class_name Gate extends Node2D


var target_y := 0.0

@export var pulley: Pulley
@export var open_height := 44.0

@onready var animatable_body: AnimatableBody2D = $AnimatableBody2D
@onready var close_sound: AudioStreamPlayer2D = $CloseSound


func _ready() -> void:
	pulley.progress_changed.connect(_on_progress_changed)


func _physics_process(_delta: float) -> void:
	var pending := target_y - animatable_body.position.y
	var collided := animatable_body.test_move(animatable_body.global_transform, Vector2(0, pending))
	
	if pending > 0 and collided:
		pulley.jammed = true
	else:
		animatable_body.position.y = target_y
		pulley.jammed = false


func _on_progress_changed(progress: float) -> void:
	target_y = -open_height * progress
	if progress == 0.0:
		close_sound.play()
