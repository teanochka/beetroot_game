extends HBoxContainer

@onready var checkbox_texture = $Container/Checkbox
@onready var label = $Task

var checked_texture = preload("res://assets/checkbox_checked.png")
var unchecked_texture = preload("res://assets/checkbox.png")

func set_task_text(text: String):
	label.text = text

func set_completed(completed: bool):
	if completed:
		checkbox_texture.texture = checked_texture
		label.modulate = Color(0.5, 0.5, 0.5)  # Серый цвет для выполненных
	else:
		checkbox_texture.texture = unchecked_texture
		label.modulate = Color(1, 1, 1)  # Белый цвет для активных
