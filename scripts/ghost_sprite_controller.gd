extends Sprite2D
class_name SpriteController

enum BuildingType { CONVEYOR, SPLITTER, OTHER }

var building_type: BuildingType = BuildingType.OTHER

func setup_with_building_data(building_data: BuildingData) -> void:
	if not building_data:
		return
	
	if building_data.building_type == "conveyor":
		building_type = BuildingType.CONVEYOR
		_setup_conveyor_sheet()
	elif building_data.building_type == "splitter":
		building_type = BuildingType.SPLITTER
		_setup_splitter_sheet()
	else:
		building_type = BuildingType.OTHER
		_setup_regular_sprite(building_data)

func set_direction(direction: Enums.Direction) -> void:
	match building_type:
		BuildingType.CONVEYOR:
			_set_conveyor_frame(direction)
		BuildingType.SPLITTER:
			_set_splitter_frame(direction)
		BuildingType.OTHER:
			pass

func set_offset_y(offset_y: float) -> void:
	offset.y = offset_y

func _setup_conveyor_sheet() -> void:
	texture = load("res://assets/conveyor-sheet.png")
	hframes = 5
	vframes = 3
	frame = 0

func _setup_splitter_sheet() -> void:
	texture = load("res://assets/splitter_sheet.png")
	hframes = 2
	vframes = 2
	frame = 0

# Настройка обычного спрайта
func _setup_regular_sprite(building_data: BuildingData) -> void:
	texture = building_data.sprite
	hframes = 1
	vframes = 1
	frame = 0
	offset = Vector2(0, building_data.sprite_offset)

func _set_conveyor_frame(direction: Enums.Direction) -> void:
	match direction:
		Enums.Direction.Left:
			frame = 1
		Enums.Direction.Down:
			frame = 5
		Enums.Direction.Up:
			frame = 7
		Enums.Direction.Right:
			frame = 11
		_:
			frame = 0

func _set_splitter_frame(from_direction: Enums.Direction) -> void:
	match from_direction:
		Enums.Direction.Left:
			frame = 1
		Enums.Direction.Right:
			frame = 0
		Enums.Direction.Up:
			frame = 3
		Enums.Direction.Down:
			frame = 2
		_:
			frame = 0
