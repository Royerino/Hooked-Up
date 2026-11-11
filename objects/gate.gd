class_name Gate extends Node2D


@onready var animatable_body: AnimatableBody2D = $AnimatableBody2D

@export var pulley: Pulley
@export var open_height := 44.0


func _ready() -> void:
	pulley.progress_changed.connect(_on_progress_changed)


func _physics_process(_delta: float) -> void:
	pulley.jammed = animatable_body.test_move(animatable_body.global_transform, Vector2(0, 2))


func _on_progress_changed(progress: float) -> void:
	animatable_body.position.y = -open_height * progress
