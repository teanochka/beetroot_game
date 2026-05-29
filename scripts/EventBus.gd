extends Node

var isBuilding: bool = false
var isDeconstructing: bool = false
var is_ui_visible: bool = false
var is_dialogue_visible: bool = false

signal tutorial_task_completed(task_type: String)

signal current_task_changed(task_type: String)

signal conveyor_clicked(global_position: Vector2, whitelist: Array[String], blacklist: Array[String])
signal building_placed(location: Vector2, building_type: String, direction: Enums.Direction)

func emit_current_task_changed(task_type: String):
	current_task_changed.emit(task_type)
	print("Event bus sending task changed")

func emit_task_completed(task_type: String):
	tutorial_task_completed.emit(task_type)

func emit_conveyor_clicked(global_position: Vector2, whitelist: Array[String], blacklist: Array[String]):
	conveyor_clicked.emit(global_position, whitelist, blacklist)
	print("Conveyor clicked at position: ", global_position)
	print("Whitelist: ", whitelist)
	print("Blacklist: ", blacklist)

func emit_building_placed(location: Vector2, building_type: String, direction: Enums.Direction):
	building_placed.emit(location, building_type, direction)
