extends Button

var building_type: String
var building_data: Dictionary
var game_manager: Node

func setup(type: String, data: Dictionary, manager: Node):
	building_type = type
	building_data = data
	game_manager = manager
	
	text = "%s - %dG" % [data["name"], data["price"]]
	
	# Проверяем, хватает ли денег
	check_affordability()
	
	# Подключаем сигнал изменения денег
	game_manager.money_changed.connect(check_affordability)
	
	# Подключаем клик
	pressed.connect(on_button_pressed)

func check_affordability():
	disabled = !game_manager.can_afford_building(building_type)

func on_button_pressed():
	if game_manager.purchase_building(building_type):
		print("Успешно куплено: ", building_data["name"])
		# Здесь можно добавить логику размещения постройки
	else:
		print("Недостаточно денег для: ", building_data["name"])
