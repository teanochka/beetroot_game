extends CanvasLayer

@onready var deconstruction_label: Label = $DeconstructionLabel
@onready var money_label: Label = $MoneyLabel
@onready var building_menu: Panel = $BuildingMenu
@onready var buildings_list: VBoxContainer = $BuildingMenu/MarginContainer/ScrollContainer/BuildingsList

var list_item_scene = preload("res://scenes/building_list_item.tscn")
var building_data_dir = "res://resources/buildings/"
var building_resources: Array[BuildingData] = []
var player_money: int = 4000
var is_visible: bool = false
var can_build: bool = true
signal building_selected(building_data: BuildingData) 


func _ready():
	building_menu.hide()
	clear_buildings_list()
	load_building_resources()
	money_label.update_display(player_money)
	deconstruction_label.hide()
	
	
func clear_buildings_list():
	for child in buildings_list.get_children():
		child.queue_free()
		
func load_building_resources():
	var dir = DirAccess.open(building_data_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource_path = building_data_dir + file_name
				var building_data = load(resource_path)
				if building_data is BuildingData:
					building_resources.append(building_data)
			file_name = dir.get_next()
		
		sort_buildings_by_price()
		populate_buildings_list()

func sort_buildings_by_price():
	building_resources.sort_custom(func(a, b): return a.build_price < b.build_price)

func populate_buildings_list():
	for building_data in building_resources:
		var list_item = list_item_scene.instantiate()
		buildings_list.add_child(list_item)
		list_item.set_affordability(can_afford(building_data.build_price))
		list_item.buy_button.pressed.connect(_on_building_pressed.bind(building_data))
		
		if not list_item.is_connected("prevent_buildind", _on_list_item_prevent_buildind):
			list_item.prevent_buildind.connect(_on_list_item_prevent_buildind)
		if not list_item.is_connected("continue_building", _on_list_item_continue_building):
			list_item.continue_building.connect(_on_list_item_continue_building)
		
		list_item.setup(building_data)

func _on_building_pressed(building_data: BuildingData):
	if can_afford(building_data.build_price):
		building_selected.emit(building_data)
		
func try_buy_building(building_price) -> bool:
	if can_build:
		if can_afford(building_price):
			player_money -= building_price
			money_label.update_display(player_money)
			update_buttons_availability()
			return true
		else: 
			update_buttons_availability()
			money_label.shake_and_flash()
			return false
	else: return false
	
func update_buttons_availability():
	for list_item in buildings_list.get_children():
		list_item.set_affordability(can_afford(list_item.get_building_price()))
		
func can_afford(build_price) -> bool:
	return player_money >= build_price

func _input(event: InputEvent):
	if Input.is_action_just_pressed("build_menu"):
		if is_visible:
			building_menu.hide()
		else: 
			building_menu.show()
		is_visible = !is_visible


func _on_list_item_continue_building() -> void:
	can_build = true

func _on_list_item_prevent_buildind() -> void:
	can_build = false
