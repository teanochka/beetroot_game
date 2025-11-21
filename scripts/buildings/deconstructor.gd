extends Node2D
var deconstruction_mode: bool = false
signal building_demolished(refund_amount: int)
@onready var audio_controller: Node = $"../AudioController"

func _physics_process(_delta):
	if not deconstruction_mode:
		return 	
	var pos = get_global_mouse_position()
	var location = Vector2(round(pos.x/Constants.grid_size), round(pos.y/Constants.grid_size)) * Constants.grid_size
		
	global_position = location
			
	if Input.is_action_just_pressed("left_click"):
		var building_data = BuildingCoordinator.remove_building(location)
		if building_data:
			print("Demolished", building_data.building_name)
			building_demolished.emit(building_data.build_price)
			audio_controller.play_placed()
			EventBus.emit_task_completed("delete_building")
		else:
			print("No building to demolish at this location")
			audio_controller.play_error()


func _on_ui_deconstruction_started() -> void:
	deconstruction_mode = true


func _on_ui_deconstruction_finished() -> void:
	deconstruction_mode = false
