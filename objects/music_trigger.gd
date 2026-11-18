extends Area2D


@export var music_player: AudioStreamPlayer
@export var stream: AudioStream


func _on_body_entered(body: Node2D) -> void:
	if body is Ganchez and music_player.stream != stream:
		music_player.stream = stream
		music_player.play()
