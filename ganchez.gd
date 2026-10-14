extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -350.0
const SWING_FORCE = 400
const AIR_CONTROL = 600

var is_hooked: bool = false
var hook_pos: Vector2
var rope_length: float


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Gestión de salto.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Gestión de velocidad.
	var direction := Input.get_axis("move_left", "move_right")
	_handle_horizontal_movement(direction, delta)

	move_and_slide()

	if is_hooked:
		_correct_rope_position()


func _process(delta: float) -> void:
	if velocity.x != 0 and is_on_floor():
		$Body.animation = "walk"
		$Body.play()
	else:
		$Body.stop()

	var mouse_pos = get_global_mouse_position()
	_flipCharOnMousePos(mouse_pos)
	
	var angle = $WeaponPivot.global_position.angle_to_point(mouse_pos)
	_rotateWeaponPivot(angle)
	
	if Input.is_action_just_pressed("shoot"):
		$GrapplingHook.shoot()
	
	elif Input.is_action_just_released("shoot"):
		$GrapplingHook.retrieve()


# Gira el personaje a izquierda o derecha en base a la posición del ratón.
func _flipCharOnMousePos(mouse_pos: Vector2) -> void:
	var is_mouse_pos_left_of_body = mouse_pos.x < $Body.global_position.x
	$Body.flip_h = is_mouse_pos_left_of_body
	$WeaponPivot/Arm.flip_v = is_mouse_pos_left_of_body
	$WeaponPivot/Gun.flip_v = is_mouse_pos_left_of_body
	$WeaponPivot.position.x = -5 if is_mouse_pos_left_of_body else 5
	$WeaponPivot/Arm.position.y = -5 if is_mouse_pos_left_of_body else 5


# Rota el arma limitando el ángulo a 180 grados por encima del brazo. 
func _rotateWeaponPivot(angle: float) -> void:
	if $Body.flip_h:
		if angle > 0:
			angle -= TAU
		angle = clampf(angle, -PI, -PI / 2)
	else:
		angle = clampf(angle, -PI / 2, 0)

	$WeaponPivot.rotation = angle


func _handle_horizontal_movement(direction: float, delta: float) -> void:
	# Enganchado.
	if is_hooked:
		velocity.x += direction * SWING_FORCE * delta
		_apply_rope_constraint()
	
	# En el aire.
	elif not is_on_floor() and direction:
		velocity.x += direction * AIR_CONTROL * delta
	
	# En el suelo con movimiento.
	elif direction:
		velocity.x = direction * SPEED
	
	# En el suelo sin movimiento.
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)


func _apply_rope_constraint() -> void:
	var distance: float = global_position.distance_to(hook_pos)
	# La cuerda no está tensa, no hacemos nada.
	if distance < rope_length:
		return

	var hook_to_character: Vector2 = hook_pos.direction_to(global_position)
	# Parte de la velocidad del personaje que lo aleja del ancla
	var outward_speed: float = maxf(velocity.dot(hook_to_character), 0.0)
	# Restamos esa parte para que la cuerda no se estire.
	velocity -= hook_to_character * outward_speed


func _correct_rope_position() -> void:
	if hook_pos.distance_to(global_position) > rope_length:
		global_position = hook_pos + hook_pos.direction_to(global_position) * rope_length


func _on_grappling_hook_hooked(collision_point: Vector2) -> void:
	is_hooked = true
	hook_pos = collision_point
	rope_length = hook_pos.distance_to(global_position)


func _on_grappling_hook_released() -> void:
	is_hooked = false
