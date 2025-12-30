extends Node2D

@onready var conveyor_ui: CanvasLayer = $ConveyorUI
@onready var building_ui: CanvasLayer = $BuildingUI
var selected_conveyor_position: Vector2 = Vector2.ZERO
func _ready() -> void:
	conveyor_ui.visible = false

func _physics_process(_delta):
	if !EventBus.isBuilding and !EventBus.isDeconstructing:
		if !conveyor_ui.visible and Input.is_action_just_pressed("left_click"):
			var pos = get_global_mouse_position()
			var grid_pos = Vector2(round(pos.x/Constants.grid_size), round(pos.y/Constants.grid_size)) * Constants.grid_size
			
			var building = BuildingCoordinator.get_building_at(grid_pos)
			if building != null and building.clickable:
				var building_type = building.building_data.building_type
				
				if !building_type == "splitter":
					if building_type == "conveyor":
						selected_conveyor_position = grid_pos
						conveyor_ui.visible = true
						conveyor_ui.set_lists(building.whitelist, building.blacklist)
					else:
						building_ui.open_building_ui(building_type)
		if Input.is_action_just_pressed("right_click") or Input.is_action_just_pressed("hide_menu"):
			if conveyor_ui.visible:
				var whitelist = conveyor_ui.get_whitelist()
				var blacklist = conveyor_ui.get_blacklist()
				var mode = conveyor_ui.get_mode()
				
				if selected_conveyor_position != Vector2.ZERO:
					BuildingCoordinator.update_conveyor_filters(
						selected_conveyor_position,
						whitelist,
						blacklist,
						mode
					)
			conveyor_ui.visible = false
