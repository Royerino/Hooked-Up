extends Node2D


@export_multiline() var text: String
@export var icons: Array[Texture2D]

@onready var label: Label = $Panel/Content/Label
@onready var content: HBoxContainer = $Panel/Content

func _ready() -> void:
	label.text = text
	for icon: Texture2D in icons:
		var rect := TextureRect.new()
		rect.texture = icon
		rect.custom_minimum_size = Vector2(16, 16)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		content.add_child(rect)
