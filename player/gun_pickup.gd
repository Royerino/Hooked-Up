class_name GunPickup extends Area2D


var time := 0.0

@onready var gun_sprite: Sprite2D = $Sprite2D


func _process(delta: float) -> void:
	time += delta
	
	# Animar la pistola arriba y abajo.
	gun_sprite.position.y = sin(time * 3.0) * 2.0
	
	# Animar el giro de la pistola.
	gun_sprite.scale.x = cos(time * 2.0)


func _on_body_entered(body: Node2D) -> void:
	if body is Ganchez:
		body.set_has_gun(true)
		queue_free()
