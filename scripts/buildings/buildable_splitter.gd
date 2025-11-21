extends Buildable

var to_directions: Array[Enums.Direction] = []
var from_direction: Enums.Direction = Enums.Direction.Right
var splitter_scene = preload("res://scenes/conveyors/splitter.tscn")

func _ready():
	var default_directions: Array[Enums.Direction] = [Enums.Direction.Right, Enums.Direction.Up, Enums.Direction.Down]
	$DirectionController.set_directions(default_directions)
	to_directions = default_directions
	determine_from_direction()
	set_direction()

func setup_with_data(building_data: BuildingData):
	pass

func rotate_clockwise():
	$DirectionController.rotate_right()

func rotate_counter():
	$DirectionController.rotate_left()

func can_place(location: Vector2):
	return !BuildingCoordinator.check_location(location)

func place(location: Vector2):
	var splitter = splitter_scene.instantiate()
	var current_directions = $DirectionController.get_directions()
	splitter.directions = current_directions
	splitter.global_position = location
	get_tree().current_scene.add_child(splitter)
	print("BuildableSplitter: создан сплиттер")

func determine_from_direction():
	for direction in Enums.Direction.values():
		if not to_directions.has(direction):
			from_direction = direction
			break

func set_direction():
	if has_node("SplitterSpriteController"):
		$SplitterSpriteController.set_sprite_frame(from_direction)

func update_to_direction(new_directions: Array[Enums.Direction]):
	to_directions = new_directions
	determine_from_direction()
	set_direction()

func _on_from_direction_controller_direction_changed():
	determine_from_direction()
	set_direction()

func _on_direction_controller_directions_changed(new_directions: Array[Enums.Direction]):
	update_to_direction(new_directions)
