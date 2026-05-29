extends Node
class_name Buildable

func rotate_clockwise():
	pass

func rotate_counter():
	pass

func can_place(location: Vector2):
	pass

func place(location: Vector2):
	pass

func get_placement_direction() -> Enums.Direction:
	return Enums.Direction.Right
