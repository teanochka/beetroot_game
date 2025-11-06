extends TileMapLayer

@onready var ghost_building = $GhostBuilding
@onready var building_ui = $"../BuildingUI"
@onready var ui = $"../UI"

var selected_building_key: String = ""
var selected_building_texture: Texture2D
var is_placing: bool = false
var is_deleting: bool = false
var occupied_cells:={}
var busy_stations: Dictionary = {}
var tutorial 
# Текущее направление конвейера (по умолчанию - вправо)

var current_conveyor_direction: int = 0
const MAX_BUILDING_HEIGHT: int = -3

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
	tutorial = get_tree().get_first_node_in_group("Tutorial")
	add_to_group("BuildingPlacer")
	ghost_building.visible = false
	
	spawn_initial_buildings()
	
	var game_manager = get_tree().get_first_node_in_group("GameManager")

	if game_manager:
		print("BuildingPlacer: GameManager найден, подключаем building_selected...")
		game_manager.building_selected.connect(_on_building_selected)
	else:
		print("BuildingPlacer: ОШИБКА: GameManager не найден!")
func is_height_allowed(cell: Vector2i) -> bool:
	return cell.y >= MAX_BUILDING_HEIGHT

func _on_building_selected(building_key: String, texture: Texture2D):
	print("BuildingPlacer: Получен сигнал building_selected для: ", building_key)
	
	# Выходим из режима удаления если активен
	if is_deleting:
		exit_delete_mode()
	
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
	# Обработка входа/выхода из режима удаления
	if event.is_action_pressed("destruction"):
		if is_deleting:
			exit_delete_mode()
		else:
			enter_delete_mode()
	elif event.is_action_pressed("hide_menu"):
		if is_deleting:
			exit_delete_mode()
		elif is_placing:
			cancel_placement()
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell = get_mouse_cell()
		print("Нажата клетка: ", cell, map_to_local(cell))
		
		# Если в режиме удаления - удаляем постройку
		if is_deleting:
			delete_building_at_cell(cell)
			return
		
		# Дополнительная информация о клетке
		if is_cell_occupied(cell):
			building_ui.open_building_ui(occupied_cells[cell])
			tutorial.complete_task_by_type("open_building_ui")
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
		if not is_height_allowed(cell):
			ghost_building.modulate = Color(1, 0.2, 0.2, 0.7)
		elif is_cell_occupied(cell):
			ghost_building.modulate = Color(1, 0.3, 0.3, 0.7)
		else:
			ghost_building.modulate = Color(0.3, 1, 0.3, 0.7)
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_place_building()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()
	
	# Обработка вращения конвейера клавишей R
	if event.is_action_pressed("rotate") and selected_building_key.begins_with("conveyor"):
		rotate_conveyor()

# Режим удаления построек
func enter_delete_mode():
	is_deleting = true
	is_placing = false  # Выходим из режима строительства
	selected_building_key = ""
	selected_building_texture = null
	ghost_building.visible = false
	print("Режим удаления построек активирован. Нажмите Q или ESC для выхода.")
	if ui:
		ui.toggle_deconstruction_label(true)

func exit_delete_mode():
	is_deleting = false
	print("Режим удаления построек деактивирован.")
	if ui:
		ui.toggle_deconstruction_label(false)

# Удаление постройки в указанной клетке
func delete_building_at_cell(cell: Vector2i):
	if not is_cell_occupied(cell):
		print("В клетке ", cell, " нет постройки для удаления")
		return
	
	# Находим и удаляем визуальную постройку
	var building_type = occupied_cells[cell]
	var buildings_node = get_parent().get_node("Buildings") if get_parent().has_node("Buildings") else get_parent()
	var building_found = false
	
	# Рассчитываем ожидаемую позицию так же, как при создании построек
	var cell_size = tile_set.tile_size
	var expected_position = map_to_local(cell)
	
	# Добавляем такое же смещение, как в try_place_building()
	var sprite_height = 0
	var building_texture = null
	
	# Определяем текстуру для расчета высоты (как в try_place_building)
	if building_type.begins_with("conveyor"):
		# Для конвейеров используем текущую текстуру призрака или загружаем по типу
		var direction = "right"
		if building_type == "conveyor_down": direction = "down"
		elif building_type == "conveyor_left": direction = "left"
		elif building_type == "conveyor_up": direction = "up"
		
		var texture_path = "res://assets/conveyorR.png"
		match direction:
			"down": texture_path = "res://assets/conveyorD.png"
			"left": texture_path = "res://assets/conveyorL.png"
			"up": texture_path = "res://assets/conveyorU.png"
		
		building_texture = load(texture_path)
	else:
		# Для других построек загружаем текстуру
		match building_type:
			"cleaner":
				building_texture = preload("res://assets/cleaner.png")
			"diffuser":
				building_texture = preload("res://assets/diffuser.png")
			"evaporator":
				building_texture = preload("res://assets/evaporator.png")
			"crystallizer":
				building_texture = preload("res://assets/crystallizer.png")
			"packer":
				building_texture = preload("res://assets/packer.png")
			"importer":
				building_texture = preload("res://assets/importer.png")
			"exporter":
				building_texture = preload("res://assets/exporter.png")
			"splitter":
				building_texture = preload("res://assets/splitterR.png")
	
	if building_texture:
		sprite_height = building_texture.get_height()
		var offset = Vector2(0, (cell_size.y / 2) - (sprite_height / 2))
		expected_position += offset
	
	print("Ищем постройку '", building_type, "' в клетке ", cell)
	print("Ожидаемая позиция: ", expected_position)
	
	for child in buildings_node.get_children():
		var building_pos = child.position
		var distance = building_pos.distance_to(expected_position)
		
		# Увеличиваем допуск
		var tolerance = cell_size.x * 0.6  # 60% размера клетки
		
		print("  Проверяем постройку at ", building_pos, " (расстояние: ", distance, ")")
		
		if distance < tolerance:
			child.queue_free()
			building_found = true
			print("Удалена постройка типа '", building_type, "' в клетке ", cell)
			break
	
	if not building_found:
		print("Визуальная постройка в клетке ", cell, " не найдена!")
		print("Доступные постройки и их позиции:")
		for child in buildings_node.get_children():
			var child_type = child.get_meta("building_type", "unknown")
			print("  - ", child_type, " at ", child.position)
	
	# Удаляем из occupied_cells независимо от того, нашли ли визуальную постройку
	occupied_cells.erase(cell)
	busy_stations.erase(cell)
	
	set_meta("occupied_cells", occupied_cells)
	if tutorial:
		tutorial.complete_task_by_type("delete_building")
# Функция для вращения конвейера
func rotate_conveyor():
	if not selected_building_key.begins_with("conveyor"):
		return
	
	current_conveyor_direction = (current_conveyor_direction + 1) % conveyor_directions.size()
	update_conveyor_ghost()
	if tutorial:
		tutorial.complete_task_by_type("rotate_conveyor")
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
	
	# Проверяем высоту
	if not is_height_allowed(cell):
		print("Нельзя строить выше клетки Y = ", MAX_BUILDING_HEIGHT, "! Текущая клетка: ", cell)
		ghost_building.modulate = Color(1, 0.2, 0.2, 0.7) 
		return
	
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
		if tutorial:
			tutorial.complete_task_by_type("build_conveyor")
	else:
		create_building(selected_building_key, world_pos, selected_building_texture)
		occupied_cells[cell] = selected_building_key
		if tutorial:
			tutorial.complete_task_by_building(selected_building_key)
	set_meta("occupied_cells", occupied_cells)
	finish_placement()

func create_building(building_key: String, position: Vector2, texture: Texture2D):
	var building_instance = preload("res://scenes/building.tscn").instantiate()
	building_instance.position = position 
	building_instance.get_node("Sprite2D").texture = texture
	
	# Устанавливаем Z-index на основе Y-координаты для правильного порядка отрисовки
	building_instance.z_index = int(position.y)
	
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
	
func spawn_initial_buildings():
	print("Спавним стартовые постройки...")
	
	# Импортер в клетке (-5, -3)
	var importer_cell = Vector2i(-5, -3)
	var importer_pos = map_to_local(importer_cell)
	var cell_size = tile_set.tile_size
	var importer_texture = preload("res://assets/importer.png")
	var sprite_height = importer_texture.get_height() if importer_texture else 0
	var offset = Vector2(0, (cell_size.y / 2) - (sprite_height / 2))
	importer_pos += offset
	
	create_building("importer", importer_pos, importer_texture)
	occupied_cells[importer_cell] = "importer"
	print("Импортер размещен в клетке: ", importer_cell, map_to_local(importer_cell))
	
	# Конвейер вниз в клетке (-4, -3)
	var conveyor_cell = Vector2i(-4, -3)
	var conveyor_pos = map_to_local(conveyor_cell)
	var conveyor_data = conveyor_directions[1] # conveyor_down (индекс 1)
	var conveyor_texture = load(conveyor_data["texture"])
	sprite_height = conveyor_texture.get_height()
	offset = Vector2(0, (cell_size.y / 2) - (sprite_height / 2))
	conveyor_pos += offset
	
	create_building(conveyor_data["key"], conveyor_pos, conveyor_texture)
	occupied_cells[conveyor_cell] = conveyor_data["key"]
	print("Конвейер (вниз) размещен в клетке: ", conveyor_cell)
	conveyor_cell = Vector2i(-4, -2)
	conveyor_pos = map_to_local(conveyor_cell)
	conveyor_pos += offset
	create_building(conveyor_data["key"], conveyor_pos, conveyor_texture)
	occupied_cells[conveyor_cell] = conveyor_data["key"]
	
	var exporter_cell = Vector2i(6, -3)
	var exporter_pos = map_to_local(exporter_cell)
	var exporter_texture = preload("res://assets/exporter.png")
	sprite_height = exporter_texture.get_height() if exporter_texture else 0
	offset = Vector2(0, (cell_size.y / 2) - (sprite_height / 2))
	exporter_pos += offset
	create_building("exporter", exporter_pos, exporter_texture)
	occupied_cells[exporter_cell] = "exporter"


	
	set_meta("occupied_cells", occupied_cells)
	

func is_station_busy(cell: Vector2i) -> bool:
	var is_busy = busy_stations.get(cell, false)
	#print("Проверка занятости станции в клетке ", cell, ": ", is_busy)
	return is_busy

func set_station_busy(cell: Vector2i, busy: bool):
	busy_stations[cell] = busy
	print(cell, busy)
	print("Текущие занятые станции: ", busy_stations)


func show_conveyor_ghost(show: bool, cell: Vector2i = Vector2i.ZERO):
	if show:
		ghost_building.texture = load("res://assets/conveyorR.png")
		ghost_building.modulate = Color(1, 1, 0, 0.7)  # Желтый цвет
		
		var cell_size = tile_set.tile_size
		var sprite_height = ghost_building.texture.get_height()
		var offset = Vector2(0, (cell_size.y / 2) - (sprite_height / 2))
		ghost_building.position = map_to_local(cell) + offset
		
		ghost_building.visible = true
		print("Показан желтый призрак конвейера в клетке: ", cell)
	else:
		ghost_building.visible = false
		print("Скрыт желтый призрак конвейера")
