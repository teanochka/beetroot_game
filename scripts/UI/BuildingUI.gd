extends CanvasLayer

@onready var current_building = $MarginContainer/Panel/MarginContainer/Variable/StationName
@onready var variable_name = $MarginContainer/Panel/MarginContainer/Variable/VariableName
@onready var variable = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer/value
@onready var production_speed = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer2/ProductionSpeed
@onready var success_chance = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer2/SuccessChance
@onready var up_button = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer/VBoxContainer/UpButton
@onready var down_button = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer/VBoxContainer/DownButton

var current_building_ref: Building
# --- Данные о зданиях ---
var building_data = [
	{
		"key": "cleaner", 
		"name": "Очистительная станция",
		"variable": "Скорость оборотов",
		"variable_value": 1,
		"process_time": 10.0,
		"success_chance": 1.0,
		"input_type": "raw",
		"output_type": "chips"
	},
	{
		"key": "diffuser", 
		"name": "Диффузор",
		"variable": "Давление подачи",
		"variable_value": 1,
		"process_time": 15.0,
		"success_chance": 0.95,
		"input_type": "chips",
		"output_type": "juice"
	},
	{
		"key": "evaporator",
		"name": "Выпарной аппарат", 
		"variable": "Температура кипения",
		"variable_value": 1,
		"process_time": 20.0,
		"success_chance": 0.9,
		"input_type": "juice",
		"output_type": "syrup"
	},
	{
		"key": "crystallizer",
		"name": "Кристаллизатор",
		"variable": "Интенсивность охлаждения",
		"variable_value": 1,
		"process_time": 30.0,
		"success_chance": 0.85,
		"input_type": "syrup",
		"output_type": "wet_sugar"
	},
	{
		"key": "packer",
		"name": "Упаковщик",
		"variable": "Скорость упаковки",
		"variable_value": 1,
		"process_time": 30.0,
		"success_chance": 0.95,
		"input_type": "wet_sugar",
		"output_type": "packed_sugar"
	}
]

# Текущие параметры активной постройки
var current_data := {}
var current_index: int = -1
var variable_value: int = 0


func _ready():
	hide()
	up_button.pressed.connect(_on_up_pressed)
	down_button.pressed.connect(_on_down_pressed)

func open_building_ui(building: Building):
	current_building_ref = building
	
	if not current_building_ref or not current_building_ref.building_data:
		print("No building or building data found!")
		return
	
	var building_data = current_building_ref.get_ui_data()
	
	current_building.text = building_data["name"]
	variable_name.text = building_data["variable"]
	variable.text = str(building_data["variable_value"])
	production_speed.text = "Время: " + str(round(building_data["process_time"])) + " сек"
	success_chance.text = "Шанс успеха: " + str(round(building_data["success_chance"] * 100)) + "%"
	
	show()
	print("Opened UI for: ", building_data["name"])

func _on_up_pressed():
	if not current_building_ref:
		return
	
	# Получаем текущие значения
	var current_data = current_building_ref.get_ui_data()
	var new_variable_value = current_data["variable_value"] + 1
	var new_process_time = max(0.5, current_data["process_time"] * 0.95)
	var new_success_chance = max(0.1, current_data["success_chance"] - 0.1)
	
	# Обновляем реальную постройку
	current_building_ref.update_parameters(new_variable_value, new_process_time, new_success_chance)
	
	# Обновляем UI с новыми значениями
	_update_ui()

func _on_down_pressed():
	if not current_building_ref:
		return
	
	# Получаем текущие значения
	var current_data = current_building_ref.get_ui_data()
	var current_variable_value = current_data["variable_value"]
	
	if current_variable_value <= 0:
		return
	
	var new_variable_value = current_variable_value - 1
	var new_process_time = current_data["process_time"] * 1.05
	var new_success_chance = min(1.0, current_data["success_chance"] + 0.1)
	
	# Обновляем реальную постройку
	current_building_ref.update_parameters(new_variable_value, new_process_time, new_success_chance)
	
	# Обновляем UI с новыми значениями
	_update_ui()

func _update_ui():
	if not current_building_ref:
		return
	
	var current_data = current_building_ref.get_ui_data()
	variable.text = str(current_data["variable_value"])
	production_speed.text = "Время: " + str(round(current_data["process_time"])) + " сек"
	success_chance.text = "Шанс успеха: " + str(round(current_data["success_chance"] * 100)) + "%"
	
	print("UI updated - New values:")
	print("  Variable: ", current_data["variable_value"])
	print("  Process time: ", current_data["process_time"])
	print("  Success chance: ", current_data["success_chance"])

func _input(event):
	if event.is_action_pressed("hide_menu"):
		hide()
