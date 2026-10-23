class_name Ganchez extends CharacterBody2D


const SPEED = 300.0
const AIR_MAX_SPEED = SPEED
const JUMP_VELOCITY = -425.0
const SWING_FORCE = 300
const AIR_CONTROL = 700
const GRAVITY_SCALE = 1.5
const JUMP_CUT_FACTOR = 0.5
const ROPE_TOLERANCE = 1.0

var is_hooked := false
var controllable := true
var hook_pos := Vector2.ZERO
var rope_length := 0.0
var anchor_velocity := Vector2.ZERO

@onready var grappling_hook: GrapplingHook = $GrapplingHook
@onready var body: AnimatedSprite2D = $Body
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var arm: Sprite2D = $WeaponPivot/Arm
@onready var gun: Sprite2D = $WeaponPivot/Gun
@onready var camera_2d: Camera2D = $Camera2D


func _physics_process(delta: float) -> void:
	if not controllable:
		return
		
	# Si está enganchado se calcula la velocidad del objeto al que está enganchado y su posición.
	if is_hooked:
		var new_hook_pos: Vector2 = grappling_hook.get_anchor_position()
		anchor_velocity = (new_hook_pos - hook_pos) / delta
		hook_pos = new_hook_pos
		
	# Reducir la gravedad cuando está enganchado.
	if not is_on_floor():
		var gravity_scale := GRAVITY_SCALE if not is_hooked else 1.0
		velocity += get_gravity() * gravity_scale * delta

	# Gestión de salto.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_released("jump") and velocity.y < 0 and not is_hooked:
		velocity.y *= JUMP_CUT_FACTOR

	# Gestión de velocidad.
	var direction := Input.get_axis("move_left", "move_right")
	_handle_horizontal_movement(direction, delta)

	move_and_slide()

	if is_hooked:
		_correct_rope_position(delta)


func _process(_delta: float) -> void:
	if velocity.x != 0 and is_on_floor():
		body.play("walk")
	elif !is_on_floor():
		body.play("jump")
	else:
		body.play("idle")

	var mouse_pos = get_global_mouse_position()
	_flip_char_on_mouse_pos(mouse_pos)
	
	var angle = weapon_pivot.global_position.angle_to_point(mouse_pos)
	_rotate_weapon_pivot(angle)
	
	if Input.is_action_just_pressed("shoot"):
		grappling_hook.shoot()
	
	elif Input.is_action_just_released("shoot"):
		grappling_hook.retrieve()


func set_controllable(value: bool) -> void:
	controllable = value
	if not value:
		velocity = Vector2.ZERO
		grappling_hook.reset()


func respawn_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	grappling_hook.reset()
	controllable = true


func set_camera_limits(rect: Rect2) -> void:
	camera_2d.set_limit(SIDE_LEFT, int(rect.position.x))
	camera_2d.set_limit(SIDE_TOP, int(rect.position.y))
	camera_2d.set_limit(SIDE_RIGHT, int(rect.end.x))
	camera_2d.set_limit(SIDE_BOTTOM, int(rect.end.y))


# Gira el personaje a izquierda o derecha en base a la posición del ratón.
func _flip_char_on_mouse_pos(mouse_pos: Vector2) -> void:
	var is_mouse_pos_left_of_body = mouse_pos.x < body.global_position.x
	body.flip_h = is_mouse_pos_left_of_body
	arm.flip_v = is_mouse_pos_left_of_body
	gun.flip_v = is_mouse_pos_left_of_body
	weapon_pivot.position.x = -5 if is_mouse_pos_left_of_body else 5
	arm.position.y = -5 if is_mouse_pos_left_of_body else 5


# Rota el arma limitando el ángulo a 180 grados por encima del brazo. 
func _rotate_weapon_pivot(angle: float) -> void:
	if body.flip_h:
		if angle > 0:
			angle -= TAU
		angle = clampf(angle, -PI, -PI / 2)
	else:
		angle = clampf(angle, -PI / 2, 0)

	weapon_pivot.rotation = angle


func _handle_horizontal_movement(direction: float, delta: float) -> void:
	# Enganchado.
	if is_hooked:
		velocity.x += direction * SWING_FORCE * delta
		_apply_rope_constraint()
	
	# En el aire.
	elif not is_on_floor() and direction:
		var speed_limit := maxf(absf(velocity.x), AIR_MAX_SPEED)
		var new_speed := velocity.x + direction * AIR_CONTROL * delta
		velocity.x = clampf(new_speed, -speed_limit, speed_limit)
	
	# En el suelo con movimiento.
	elif direction:
		velocity.x = direction * SPEED
	
	# En el suelo sin movimiento.
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)


func _apply_rope_constraint() -> void:
	var distance: float = global_position.distance_to(hook_pos)
	# La cuerda no está tensa (con margen por errores de redondeo), no hacemos nada.
	if distance < rope_length - ROPE_TOLERANCE:
		return

	var hook_to_character: Vector2 = hook_pos.direction_to(global_position)
	# Velocidad del personaje vista desde el ancla.
	var relative_velocity: Vector2 = velocity - anchor_velocity
	# Parte de esa velocidad que lo aleja del ancla.
	var outward_speed: float = maxf(relative_velocity.dot(hook_to_character), 0.0)
	# Restamos esa parte para que la cuerda no se estire.
	velocity -= hook_to_character * outward_speed


func _correct_rope_position(delta: float) -> void:
	# Corrige donde estará el ancla.
	var next_anchor: Vector2 = hook_pos + anchor_velocity * delta
	if next_anchor.distance_to(global_position) > rope_length:
		global_position = next_anchor + next_anchor.direction_to(global_position) * rope_length


func _on_grappling_hook_hooked(collision_point: Vector2) -> void:
	is_hooked = true
	hook_pos = collision_point
	rope_length = hook_pos.distance_to(global_position)
	anchor_velocity = Vector2.ZERO


func _on_grappling_hook_released() -> void:
	is_hooked = false
	anchor_velocity = Vector2.ZERO
