@tool
extends Node2D


@export_multiline() var text: String:
	set(value):
		text = value
		if is_node_ready():
			_set_label()
@export var icons: Array[Texture2D]:
	set(value):
		icons = value
		if is_node_ready():
			_set_icons()

@onready var label: Label = $Panel/Content/Label
@onready var content: HBoxContainer = $Panel/Content


func _ready() -> void:
	_set_label()
	_set_icons()


func _set_label() -> void:
	label.text = text


func _set_icons() -> void:
	for child: Node in content.get_children():
		if child is TextureRect:
			content.remove_child(child)
			child.queue_free()

	for icon: Texture2D in icons:
		var rect := TextureRect.new()
		rect.texture = icon
		rect.custom_minimum_size = Vector2(16, 16)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		content.add_child(rect)
