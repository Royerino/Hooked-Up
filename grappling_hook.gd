extends Node2D


signal hooked
signal released

enum State { IDLE, FLYING, RETRACTING, HOOKED }

var state: State = State.IDLE
var direction: Vector2
var collision_point: Vector2

@export var muzzle: Marker2D
@export var character: CharacterBody2D
@export var rope_max_length: float = 300
@export var rope_velocity: float = 1500


func _ready() -> void:
	$RayCast2D.add_exception(character)


func _process(delta: float) -> void:
	if state != State.IDLE:
		$Rope.set_point_position(0, muzzle.global_position)
		
	match state:
		State.RETRACTING:
			_process_retracting(delta)
		State.HOOKED:
			_process_hooked(delta)


func _physics_process(delta: float) -> void:
	match state:
		State.FLYING:
			_process_flying(delta)


func shoot() -> void:
	if state != State.IDLE:
		return

	$Rope.visible = true
	$Hook.visible = true

	$Rope.add_point(muzzle.global_position)
	$Rope.add_point(muzzle.global_position)

	$Hook.position = muzzle.global_position
	$Hook.rotation = muzzle.global_rotation
	direction = Vector2.from_angle(muzzle.global_rotation)

	state = State.FLYING


func retrieve() -> void:
	if state not in [State.FLYING, State.HOOKED]:
		return

	if state == State.HOOKED:
		released.emit()

	state = State.RETRACTING


func _process_flying(delta: float) -> void:
	var current_pos = $Rope.get_point_position(1)
	var new_pos: Vector2 = current_pos + direction * rope_velocity * delta
	
	# El RayCast mira si en la siguiente posición hay colisión y la gestiona.
	$RayCast2D.global_position = current_pos
	$RayCast2D.target_position = new_pos - current_pos
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		return _manage_collision()
	
	_set_hook_position(new_pos)
	
	# Si la nueva posición sobrepasa el máximo de longitud, empieza a retraerse.
	if muzzle.global_position.distance_to(new_pos) >= rope_max_length:
		retrieve()


func _process_retracting(delta: float) -> void:
	var step: float = rope_velocity * delta
	var hook_pos: Vector2 = $Rope.get_point_position(1)
	
	# Si queda menos distancia que lo que avanzaría este frame, borramos el gancho.
	if hook_pos.distance_to(muzzle.global_position) <= step:
		_reset()
	# Si no, se retrae en dirección al muzzle.
	else:
		var return_dir: Vector2 = hook_pos.direction_to(muzzle.global_position)
		_set_hook_position(hook_pos + return_dir * step)


func _process_hooked(delta: float) -> void:
	pass


func _set_hook_position(pos: Vector2) -> void:
	$Rope.set_point_position(1, pos)
	$Hook.position = pos


func _reset() -> void:
	state = State.IDLE
	$Hook.visible = false
	$Rope.visible = false
	$Rope.clear_points()


# Si el gancho colisiona contra una superficie válida, se fija en esa posición. Si no, rebota.
func _manage_collision() -> void:
	if $RayCast2D.get_collider().get_collision_layer_value(2):
		state = State.HOOKED
		collision_point = $RayCast2D.get_collision_point()
		_set_hook_position(collision_point)
		hooked.emit(collision_point)
	else:
		self.retrieve()
