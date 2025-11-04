extends TileMapLayer

@onready var ghost_building = $GhostBuilding

var selected_building_key: String = ""
var selected_building_texture: Texture2D
var is_placing: bool = false
var occupied_cells:={}

func _ready():
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
	ghost_building.texture = texture
	ghost_building.visible = true
	ghost_building.modulate = Color(1, 1, 1, 0.7)

func _input(event):


	if not is_placing:
		return
	
	if event is InputEventMouseMotion:
		var cell = get_mouse_cell()
		var cell_size = tile_set.tile_size
		var sprite_height = ghost_building.texture.get_height()
	
		var offset = Vector2(0, (cell_size.y / 2) - (sprite_height / 2))
		ghost_building.position = map_to_local(cell) + offset

		#print("mouse:", get_global_mouse_position(), " cell:", cell, " map_to_local:", map_to_local(cell))

		if is_cell_occupied(cell):
			ghost_building.modulate = Color(1, 0.3, 0.3, 0.7)
		else:
			ghost_building.modulate = Color(0.3, 1, 0.3, 0.7)
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			try_place_building()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()

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
	create_building(selected_building_key, world_pos, selected_building_texture)
	# сохраняем тип постройки в клетку
	occupied_cells[cell] = selected_building_key
	finish_placement()

func create_building(building_key: String, position: Vector2, texture: Texture2D):
	var building_instance = preload("res://scenes/building.tscn").instantiate()
	building_instance.position = position 
	building_instance.get_node("Sprite2D").texture = texture
	
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
