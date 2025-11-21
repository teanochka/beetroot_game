extends Node


var buildings = {}

func check_location(location: Vector2) -> bool:
	return buildings.has(location)

func add_building(location: Vector2, building: Node2D) -> void:
	buildings[location] = building
	print("Building placed:", building, location)
	
func remove_building(location: Vector2) -> BuildingData:
	if buildings.has(location):
		var building = buildings[location]
		if !building.is_protected:
			var building_data = building.building_data
			buildings.erase(location)
			building.queue_free()
			return building_data
	return null

func get_building_at(location: Vector2) -> Node2D:
	return buildings.get(location)
