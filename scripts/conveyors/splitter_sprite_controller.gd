extends Sprite2D

func set_sprite_frame(from: Enums.Direction):
	match from:
		Enums.Direction.Left:
			frame = 1
		Enums.Direction.Right:
			frame = 0
		Enums.Direction.Up:
			frame = 3
		Enums.Direction.Down:
			frame = 2	
