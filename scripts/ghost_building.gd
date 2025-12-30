extends Node2D
class_name GhostBuilding

var ghost_color: Color = Color.YELLOW
var alpha = 0.5

@export var building_data: BuildingData
@export var direction: Enums.Direction
@onready var sprite_controller: Sprite2D = $GhostSpriteController

var ghost_location: Vector2

func _ready():
	_apply_ghost_color()
	if building_data:
		_update_visual()

func setup(data: BuildingData, location: Vector2, ghost_direction: Enums.Direction) -> void:
	building_data = data
	ghost_location = location
	direction = ghost_direction
	
	global_position = location
	
	if sprite_controller:
		_update_visual()
	else:
		pass

func _update_visual() -> void:
	if building_data and sprite_controller:
		sprite_controller.setup_with_building_data(building_data)
		sprite_controller.set_direction(direction)
		_apply_ghost_color()

func _apply_ghost_color():
	var final_color = ghost_color
	final_color.a = alpha
	modulate = final_color

func get_location() -> Vector2:
	return ghost_location

func set_alpha(new_alpha: float) -> void:
	alpha = new_alpha
	_apply_ghost_color()
