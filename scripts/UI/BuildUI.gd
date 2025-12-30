extends CanvasLayer

@onready var deconstruction_label: Label = $DeconstructionLabel
@onready var money_label: Label = $MoneyLabel
@onready var building_menu: Panel = $BuildingMenu
@onready var buildings_list: VBoxContainer = $BuildingMenu/MarginContainer/ScrollContainer/BuildingsList

var list_item_scene = preload("res://scenes/building_list_item.tscn")
var building_paths = [
	"res://resources/buildings/cleaner.tres",
	"res://resources/buildings/conveyor.tres",
	"res://resources/buildings/crystallizer.tres",
	"res://resources/buildings/diffuser.tres",
	"res://resources/buildings/evaporator.tres",
	"res://resources/buildings/packer.tres",
	"res://resources/buildings/splitter.tres"
]
var building_resources: Array[BuildingData] = []
var player_money: int = 10000
var can_build: bool = true
var deconstruction_mode: bool = false


signal building_selected(building_data: BuildingData) 
signal deconstruction_started()
signal deconstruction_finished()


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
	building_resources.clear()
	
	for path in building_paths:
		if ResourceLoader.exists(path):
			var building_data = load(path)
			if building_data is BuildingData:
				building_resources.append(building_data)
	
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
		EventBus.emit_task_completed("select_conveyor")
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

func _toggle_build_menu():
	if deconstruction_mode:
		exit_deconstruction_mode()
	
	EventBus.isBuilding = !EventBus.isBuilding
	if EventBus.isBuilding:
		building_menu.show()
	else:
		building_menu.hide()

func _hide_all_menus():
	if deconstruction_mode:
		exit_deconstruction_mode()
	
	EventBus.isBuilding = false
	building_menu.hide()

func _toggle_deconstruction_mode():
	if deconstruction_mode:
		exit_deconstruction_mode()
	else:
		enter_deconstruction_mode()

func enter_deconstruction_mode():
	deconstruction_mode = true
	deconstruction_label.show()
	deconstruction_started.emit()
	
	if EventBus.isBuilding:
		EventBus.isBuilding = false
		building_menu.hide()
	
func exit_deconstruction_mode():
	deconstruction_mode = false
	deconstruction_label.hide()
	deconstruction_finished.emit()

func _on_list_item_continue_building() -> void:
	can_build = true

func _on_list_item_prevent_buildind() -> void:
	can_build = false

func _on_deconstructor_building_demolished(refund_amount: Variant) -> void:
	player_money += refund_amount
	money_label.update_display(player_money)
	update_buttons_availability()


func _on_exporter_item_sold(item_value: int) -> void:
	player_money += item_value
	money_label.update_display(player_money)
	update_buttons_availability()


func _on_building_menu_focus_entered() -> void:
	pass # Replace with function body.
