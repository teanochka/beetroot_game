extends CanvasLayer

var money_label: Label
var building_menu: Panel
var buildings_list: VBoxContainer

var list_item_scene = preload("res://scenes/building_list_item.tscn")

var building_data = [
	{
		"key": "conveyor",
		"name": "Конвейер",
		"price": 1,
		"description": "Основа производства",
		"texture": "res://assets/block.png"
	},
	{
		"key": "cleaner", 
		"name": "Очистительная станция",
		"price": 50,
		"description": "Очищает свеклу от примесей",
		"texture": "res://assets/block.png"
	},
	{
		"key": "evaporator",
		"name": "Выпаривающий аппарат", 
		"price": 200,
		"description": "Выпаривает воду из сиропа",
		"texture": "res://assets/block.png"
	},
	{
		"key": "crystallizer",
		"name": "Кристаллизатор",
		"price": 1000,
		"description": "Создает сахарные кристаллы", 
		"texture": "res://assets/block.png"
	},
	{
		"key": "packer",
		"name": "Упаковщик",
		"price": 2000,
		"description": "Фасует готовый сахар",
		"texture": "res://assets/block.png"
	}
]

func _ready():
	# Находим основные ноды
	money_label =$MoneyLabel
	building_menu = $BuildingMenu
	buildings_list = $BuildingMenu/MarginContainer/BuildingsList
	
	if building_menu:
		building_menu.visible = false
	
	print("Всего построек в данных: ", building_data.size())
	await get_tree().process_frame
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	if not game_manager:
		push_error("GameManager не найден!")
		return


	populate_buildings_list()
	game_manager.money_changed.connect(update_money_display)


func populate_buildings_list():
	if not buildings_list:
		print("ОШИБКА: BuildingsList не найден!")
		return
	
	# Очищаем список
	for child in buildings_list.get_children():
		child.queue_free()
	
	# Создаем элементы из сцены
	for i in range(building_data.size()):
		var building = building_data[i]
		var list_item = list_item_scene.instantiate()
		buildings_list.add_child(list_item)
		
		# Ждем немного перед настройкой
		await get_tree().create_timer(0.01).timeout
		setup_list_item(list_item, building)

func setup_list_item(list_item: Node, building_info: Dictionary):
	
	# Находим дочерние ноды и меняем их значения
	var item_name = list_item.get_node("ItemInfo/ItemName") as Label
	var item_description = list_item.get_node("ItemInfo/ItemDescription") as Label
	var buy_button = list_item.get_node("ItemInfo/BuyButton") as Button
	var item_image = list_item.get_node("ItemImage") as TextureRect
	
	# Отладочная информация
	print("  ItemName найден: ", item_name != null)
	print("  ItemDescription найден: ", item_description != null)
	print("  BuyButton найден: ", buy_button != null)
	print("  ItemImage найден: ", item_image != null)
	
	if item_name:
		item_name.text = building_info["name"]
	else:
		print("  ОШИБКА: ItemName не найден!")
	
	if item_description:
		item_description.text = building_info["description"]
	
	if buy_button:
		var old_text = buy_button.text
		buy_button.text = "Купить за " + str(building_info["price"]) + "G"
		
		# Отключаем старые соединения и подключаем заново
		if buy_button.is_connected("pressed", _on_building_pressed):
			buy_button.disconnect("pressed", _on_building_pressed)
		buy_button.pressed.connect(_on_building_pressed.bind(building_info["key"], building_info["price"]))
	
	if item_image:
		var texture = load(building_info["texture"])
		if texture:
			item_image.texture = texture
		else:
			print("  ОШИБКА: Текстура не загружена: ", building_info["texture"])
	
	print("---")

func _on_building_pressed(building_key: String, price: int):
	print("Нажата кнопка для: ", building_key, " цена: ", price)
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	
	if game_manager and game_manager.purchase(price):
		print("Куплена постройка: ", building_key)
		update_buttons_availability()
		
		# Находим словарь постройки вручную
		var building_info: Dictionary = {}
		for b in building_data:
			if b["key"] == building_key:
				building_info = b
				break
		
		if building_info:
			var texture = load(building_info["texture"])
			game_manager.select_building(building_key, texture)
			print("UIManager: building_selected вызван для ", building_key)
		else:
			print("Ошибка: не найден building_key ", building_key)
	else:
		print("Недостаточно денег")



func update_buttons_availability():
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	if not game_manager:
		return
	
	print("Обновляем доступность кнопок...")
	
	for list_item in buildings_list.get_children():
		var buy_button = list_item.get_node("ItemInfo/BuyButton") as Button
		if buy_button:
			var button_text = buy_button.text
			var price_str = button_text.split(" ")[2]  # Берем третье слово
			price_str = price_str.replace("G", "")  # Убираем "G"
			var can_afford = game_manager.can_afford(int(price_str))
			buy_button.disabled = !can_afford

func update_money_display(new_money: int):
	if money_label:
		money_label.text = str(new_money) + "G"
	update_buttons_availability()

func _input(event):
	if event.is_action_pressed("build_menu") and building_menu:
		building_menu.visible = !building_menu.visible
		print("Меню видимо: ", building_menu.visible)
