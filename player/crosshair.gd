extends CanvasLayer


@export var gun_raycast: RayCast2D
@export var grappling_hook: GrapplingHook
@export var texture_hookable: Texture2D
@export var texture_blocked: Texture2D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta: float) -> void:
	$Sprite2D.position = get_viewport().get_mouse_position()
	if not gun_raycast.is_colliding():
		$Sprite2D.texture = texture_blocked
		$Sprite2D.modulate.a = 0.5
	else:
		if grappling_hook.is_hookable(gun_raycast.get_collider()):
			$Sprite2D.texture = texture_hookable
			$Sprite2D.modulate.a = 1
		else:
			$Sprite2D.texture = texture_blocked
			$Sprite2D.modulate.a = 0.5


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
