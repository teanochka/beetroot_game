extends Node2D
class_name GhostController

@onready var ghost_building_scene = preload("res://scenes/ghost_building.tscn")

var active_ghosts: Dictionary = {}

var quest_ghosts: Dictionary = {
	"conveyor": [
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(-48, -32),
			"direction": Enums.Direction.Right
		},
	],
	"cleaner": [
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(-32, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/cleaner.tres"),
			"location": Vector2(-16, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(0, -32),
			"direction": Enums.Direction.Right
		},
	],
	"sell_item": [
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(16, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(32, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(48, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(64, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(80, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(96, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(112, -32),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(128, -32),
			"direction": Enums.Direction.Up
		},
	],
	"diffuser": [
		{
			"building_data": preload("res://resources/buildings/diffuser.tres"),
			"location": Vector2(16, -32),
			"direction": Enums.Direction.Right
		},
	],
	"splitter": [
		{
			"building_data": preload("res://resources/buildings/splitter.tres"),
			"location": Vector2(-48, -32),
			"direction": Enums.Direction.Up
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(-48, -16),
			"direction": Enums.Direction.Down
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(-48, 0),
			"direction": Enums.Direction.Down
		},
		{
			"building_data": preload("res://resources/buildings/conveyor.tres"),
			"location": Vector2(-32, 0),
			"direction": Enums.Direction.Right
		},
		{
			"building_data": preload("res://resources/buildings/cleaner.tres"),
			"location": Vector2(-16, 0),
			"direction": Enums.Direction.Right
		}
	],
}

func _ready():
	var building_data = preload("res://resources/buildings/cleaner.tres")
	print(building_data)
	EventBus.current_task_changed.connect(_on_current_task_changed)

func spawn_ghosts_for_quest(quest_type: String) -> void:
	clear_all_ghosts()
	
	if quest_ghosts.has(quest_type):
		var ghost_configs = quest_ghosts[quest_type]
		for config in ghost_configs:
			create_ghost(
				config.building_data,
				config.location, 
				config.direction
			)

func create_ghost(building_data: BuildingData, location: Vector2, direction: Enums.Direction) -> GhostBuilding:
	remove_ghost(location)
	
	var ghost = ghost_building_scene.instantiate()
	add_child(ghost)
	
	ghost.setup(building_data, location, direction)
	active_ghosts[location] = ghost
	
	return ghost

func remove_ghost(location: Vector2) -> void:
	if active_ghosts.has(location):
		var ghost = active_ghosts[location]
		ghost.queue_free()
		active_ghosts.erase(location)

func clear_all_ghosts() -> void:
	for location in active_ghosts:
		active_ghosts[location].queue_free()
	active_ghosts.clear()

func _on_current_task_changed(task_type: String):
	spawn_ghosts_for_quest(task_type)
