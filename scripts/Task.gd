extends HBoxContainer

@onready var checkbox_texture = $Container/Checkbox
@onready var label: RichTextLabel = $Task

var checked_texture = preload("res://assets/checkbox_checked.png")
var unchecked_texture = preload("res://assets/checkbox.png")

func set_task_text(text: String):
	label.text = text

func set_completed(completed: bool):
	if completed:
		checkbox_texture.texture = checked_texture
		# Используем add_theme_color_override вместо modulate
		label.add_theme_color_override("default_color", Color(0.617, 0.617, 0.617, 1.0))
	else:
		checkbox_texture.texture = unchecked_texture
		label.add_theme_color_override("default_color", Color(1, 1, 1))
