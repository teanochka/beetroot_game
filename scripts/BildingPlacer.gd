extends TileMapLayer

@onready var ghost_building = $GhostBuilding

var selected_building_key: String = ""
var selected_building_texture: Texture2D
var is_placing: bool = false
var occupied_cells:={}

# Текущее направление конвейера (по умолчанию - вправо)
var current_conveyor_direction: int = 0

var conveyor_directions = [
	{
		"key": "conveyor_right", 
		"texture": "res://assets/conveyorR.png",
		"direction": Vector2.RIGHT
	},
	{
		"key": "conveyor_down", 
		"texture": "res://assets/conveyorD.png",
		"direction": Vector2.DOWN
	},
	{
		"key": "conveyor_left", 
		"texture": "res://assets/conveyorL.png",
		"direction": Vector2.LEFT
	},
	{
		"key": "conveyor_up",
		"texture": "res://assets/conveyorU.png",
		"direction": Vector2.UP
	}
]

func _ready():
	add_to_group("BuildingPlacer")
	ghost_building.visible = false
	
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	if game_manager:
		print("BuildingPlacer: GameManager найден, подключаем building_selected...")
		game_manager.building_selected.connect(_on_building_selected)
	else:
		print("BuildingPlacer: ОШИБКА: GameManager не найден!")

func _on_building_selected(building_key: String, texture: Texture2D):
	print("BuildingPlacer: Получен сигнал building_selected для: ", building_key)
	selected_building_key = building_key
	selected_building_texture = texture
	is_placing = true
	current_conveyor_direction = 0  # Сбрасываем направление при выборе новой постройки
	
	# Если выбран конвейер, используем текущее направление
	if building_key.begins_with("conveyor"):
		update_conveyor_ghost()
	else:
		ghost_building.texture = texture
	
	ghost_building.visible = true
	ghost_building.modulate = Color(1, 1, 1, 0.7)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell = get_mouse_cell()
		print("Нажата клетка: ", cell, " (X:", cell.x, ", Y:", cell.y, ")")
		
		# Дополнительная информация о клетке
		if is_cell_occupied(cell):
			print("  Клетка занята постройкой: ", occupied_cells[cell])
		else:
			print("  Клетка свободна")
			
	if not is_placing:
		return
	
	if event is InputEventMouseMotion:
		var cell = get_mouse_cell()
		var cell_size = tile_set.tile_size
		var sprite_height = ghost_building.texture.get_height()
	
		var offset = Vector2(0, (cell_size.y / 2) - (sprite_height / 2))
		ghost_building.position = map_to_local(cell) + offset

		if is_cell_occupied(cell):
			ghost_building.modulate = Color(1, 0.3, 0.3, 0.7)
		else:
			ghost_building.modulate = Color(0.3, 1, 0.3, 0.7)
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_place_building()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()
	
	# Обработка вращения конвейера клавишей R
	if event is InputEventKey and event.pressed and selected_building_key.begins_with("conveyor"):
		if event.keycode == KEY_R:
			rotate_conveyor()

# Функция для вращения конвейера
func rotate_conveyor():
	if not selected_building_key.begins_with("conveyor"):
		return
	
	current_conveyor_direction = (current_conveyor_direction + 1) % conveyor_directions.size()
	update_conveyor_ghost()
	print("Конвейер повернут: ", conveyor_directions[current_conveyor_direction]["key"])

# Обновление отображения призрака конвейера
func update_conveyor_ghost():
	if conveyor_directions.size() > current_conveyor_direction:
		var current_direction = conveyor_directions[current_conveyor_direction]
		ghost_building.texture = load(current_direction["texture"])

func get_mouse_cell() -> Vector2i:
	var local_mouse = to_local(get_global_mouse_position())
	return local_to_map(local_mouse)

func is_cell_occupied(cell: Vector2i) -> bool:
	return occupied_cells.has(cell)

func try_place_building():
	var cell = get_mouse_cell()
	
	if is_cell_occupied(cell):
		print("Клетка уже занята!")
		print(occupied_cells[cell]) 
		return
	
	var cell_size = tile_set.tile_size			
	var sprite_height = ghost_building.texture.get_height()
	var offset = Vector2(0, (cell_size.y / 2) - (sprite_height / 2))
	var world_pos = map_to_local(cell) + offset
	
	# Для конвейера используем текущее направление
	if selected_building_key.begins_with("conveyor"):
		var conveyor_data = conveyor_directions[current_conveyor_direction]
		create_building(conveyor_data["key"], world_pos, load(conveyor_data["texture"]))
		occupied_cells[cell] = conveyor_data["key"]
	else:
		create_building(selected_building_key, world_pos, selected_building_texture)
		occupied_cells[cell] = selected_building_key
	
	set_meta("occupied_cells", occupied_cells)
	finish_placement()

func create_building(building_key: String, position: Vector2, texture: Texture2D):
	var building_instance = preload("res://scenes/building.tscn").instantiate()
	building_instance.position = position 
	building_instance.get_node("Sprite2D").texture = texture
	
	building_instance.set_meta("building_type", building_key)
	
	var parent = get_parent()
	if parent.has_node("Buildings"):
		parent.get_node("Buildings").add_child(building_instance)
	else:
		parent.add_child(building_instance)
	
	print("Постройка размещена: ", building_key)

func cancel_placement():
	finish_placement()

func finish_placement():
	is_placing = false
	selected_building_key = ""
	selected_building_texture = null
	ghost_building.visible = false

func get_building_type_at_cell(cell: Vector2i) -> String:
	if occupied_cells.has(cell):
		return occupied_cells[cell]
	return ""
