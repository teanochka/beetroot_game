extends Buildable

var building_scene = preload("res://scenes/building.tscn")
var current_building_data: BuildingData
@onready var sprite: Sprite2D = $Sprite2D

func setup_with_data(building_data: BuildingData):
	current_building_data = building_data
	update_visual()

func update_visual():
	if current_building_data and current_building_data.sprite:
		sprite.texture = current_building_data.sprite
		sprite.offset = Vector2(0, current_building_data.sprite_offset)
			

func rotate_clockwise():
	pass

func can_place(location: Vector2):
	return !BuildingCoordinator.check_location(location)

func place(location: Vector2):
	var building = building_scene.instantiate() as Building
	
	building.building_data = current_building_data
	building.global_position = location
	
	get_tree().current_scene.add_child(building)
