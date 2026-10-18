extends Node2D


signal hooked(point: Vector2)
signal released
signal blocked(point: Vector2, normal: Vector2)

enum State { IDLE, FLYING, RETRACTING, HOOKED }

const ROPE_MAX_LENGTH: float = 180
const ROPE_VELOCITY: float = 1500

var state: State = State.IDLE
var direction: Vector2
var collision_point: Vector2

@export var muzzle: Marker2D
@export var character: CharacterBody2D


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
	var new_pos: Vector2 = current_pos + direction * ROPE_VELOCITY * delta
	
	# El RayCast mira si en la siguiente posición hay colisión y la gestiona.
	$RayCast2D.global_position = current_pos
	$RayCast2D.target_position = new_pos - current_pos
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		return _manage_collision()
	
	_set_hook_position(new_pos)
	
	# Si la nueva posición sobrepasa el máximo de longitud, empieza a retraerse.
	if muzzle.global_position.distance_to(new_pos) >= ROPE_MAX_LENGTH:
		retrieve()


func _process_retracting(delta: float) -> void:
	var step: float = ROPE_VELOCITY * delta
	var hook_pos: Vector2 = $Rope.get_point_position(1)
	
	# Si queda menos distancia que lo que avanzaría este frame, borramos el gancho.
	if hook_pos.distance_to(muzzle.global_position) <= step:
		self.reset()
	# Si no, se retrae en dirección al muzzle.
	else:
		var return_dir: Vector2 = hook_pos.direction_to(muzzle.global_position)
		_set_hook_position(hook_pos + return_dir * step)


func _process_hooked(_delta: float) -> void:
	# TODO: Añadir partículas en el lugar de impacto del gancho.
	pass


func _set_hook_position(pos: Vector2) -> void:
	$Rope.set_point_position(1, pos)
	$Hook.position = pos


func reset() -> void:
	var was_hooked := state == State.HOOKED
	state = State.IDLE
	$Hook.visible = false
	$Rope.visible = false
	$Rope.clear_points()
	if was_hooked:
		released.emit()


# Si el gancho colisiona contra una superficie válida, se fija en esa posición. Si no, rebota.
func _manage_collision() -> void:
	var point: Vector2 = $RayCast2D.get_collision_point()
	var normal: Vector2 = $RayCast2D.get_collision_normal()

	if _is_hookable($RayCast2D.get_collider(), point, normal):
		state = State.HOOKED
		collision_point = point
		_set_hook_position(point)
		hooked.emit(point)
	else:
		blocked.emit(point, normal)
		retrieve()


func _is_hookable(collider: Object, point: Vector2, normal: Vector2) -> bool:
	if collider is TileMapLayer:
		# Un pequeño paso hacia dentro del tile, para no caer en el borde entre celdas.
		var inside: Vector2 = point - normal
		var cell: Vector2i = collider.local_to_map(collider.to_local(inside))
		var data: TileData = collider.get_cell_tile_data(cell)
		return data != null and bool(data.get_custom_data("hookable"))
	# Para objetos que no son tiles.
	return collider is Node and collider.is_in_group("hookable")
