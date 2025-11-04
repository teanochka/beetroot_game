extends Area2D

signal cell_changed(cell: Vector2i)
@export var conveyor_speed: float = 100.0
var current_cell: Vector2i
var is_falling: bool = true
@onready var tilemap := get_tree().get_first_node_in_group("BuildingPlacer")

func _process(_delta):
	if tilemap:
		# смещаем проверку на полклетки вниз
		var cell_below_pos = global_position + Vector2(0, tilemap.tile_set.tile_size.y / 2)
		var new_cell = tilemap.local_to_map(tilemap.to_local(cell_below_pos))
		
		if new_cell != current_cell:
			current_cell = new_cell
			emit_signal("cell_changed", current_cell)

			
		if not is_falling:
			var building_type = check_building_below()
			if building_type == "conveyor":
				global_position.x += conveyor_speed * _delta
			elif building_type == "":
				print("Под предметом ничего нет — удаляем его.")
				queue_free()


func check_building_below() -> String:
	if not tilemap:
		return ""
	var building_type = tilemap.get_building_type_at_cell(current_cell)
	if building_type != "":
		print("Под предметом находится постройка типа:", building_type)
	else:
		print("Под предметом ничего нет")
	return building_type

func on_fall_finished():
	is_falling = false
	print("Предмет приземлился, начинаем проверку под ним...")
	var building_type = tilemap.get_building_type_at_cell(current_cell)
	if building_type == "":
		print("Под предметом ничего нет — удаляем.")
		queue_free()
