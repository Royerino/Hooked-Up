class_name Pulley extends Node2D


signal progress_changed(progress: float)

const CHAIN_REST_LENGTH := 18.0

var progress := 0.0
var hanging_body: CharacterBody2D = null
var jammed := false

@export var travel_distance := 64.0
@export var down_time := 0.4
@export var up_time := 2.0

@onready var hook_point: HookPoint = $HookPoint
@onready var chain: Sprite2D = $Chain


func _ready() -> void:
	hook_point.hooked.connect(_on_hook_point_hooked)
	hook_point.released.connect(_on_hook_point_released)


func _physics_process(delta: float) -> void:
	var is_body_hanging := hanging_body != null
	
	# Compuerta atascada (un cuerpo la bloquea).
	if not is_body_hanging and jammed:
		return
	
	# El cuerpo enganchado a la polea está tocando el suelo.
	if is_body_hanging and hanging_body.is_on_floor():
		return

	var target := 1.0 if is_body_hanging else 0.0
	var speed := 1.0 / down_time if is_body_hanging else 1.0 / up_time
	var previous_progress := progress
	
	progress = move_toward(progress, target, speed * delta)
	hook_point.position.y = travel_distance * ease(progress, -2.0)
	
	chain.region_rect.size.y = hook_point.position.y + CHAIN_REST_LENGTH
	
	if progress != previous_progress:
		progress_changed.emit(progress)


func _on_hook_point_hooked(body: CharacterBody2D) -> void:
	hanging_body = body


func _on_hook_point_released() -> void:
	hanging_body = null
