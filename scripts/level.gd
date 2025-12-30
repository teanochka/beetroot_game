extends Node2D

@onready var ui_manager: Node = $UIManager

func _ready() -> void:
	# Подключаем сигналы
	ui_manager.conveyor_filters_updated.connect(_on_conveyor_filters_updated)

func _physics_process(_delta):
	# Обработка кликов по зданиям (только если нет открытого UI)
	if !ui_manager.is_any_ui_visible and !EventBus.isBuilding and !EventBus.isDeconstructing:
		if Input.is_action_just_pressed("left_click"):
			var pos = get_global_mouse_position()
			var grid_pos = Vector2(
				round(pos.x/Constants.grid_size), 
				round(pos.y/Constants.grid_size)
			) * Constants.grid_size
			
			ui_manager.handle_building_click(grid_pos)

func _on_conveyor_filters_updated(position: Vector2, whitelist: Array, blacklist: Array, mode: String):
	BuildingCoordinator.update_conveyor_filters(position, whitelist, blacklist, mode)
