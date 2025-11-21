extends CanvasLayer

@onready var current_building = $MarginContainer/Panel/MarginContainer/Variable/StationName
@onready var variable_name = $MarginContainer/Panel/MarginContainer/Variable/VariableName
@onready var variable = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer/value
@onready var production_speed = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer2/ProductionSpeed
@onready var success_chance = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer2/SuccessChance
@onready var up_button = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer/VBoxContainer/UpButton
@onready var down_button = $MarginContainer/Panel/MarginContainer/Variable/HBoxContainer/VBoxContainer/DownButton

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


# --- ОТКРЫТИЕ UI ---
func open_building_ui(building_key: String):
	current_index = -1
	for i in range(building_data.size()):
		if building_data[i]["key"] == building_key:
			current_index = i
			current_data = building_data[i]
			break
	
	if current_index == -1:
		print("⚠️ Не найдены данные для:", building_key)
		return
	
	current_building.text = current_data["name"]
	variable_name.text = current_data["variable"]
	variable_value = current_data["variable_value"]
	_update_ui()
	show()


# --- НАЖАТИЕ НА КНОПКУ УВЕЛИЧЕНИЯ ---
func _on_up_pressed():
	if current_index == -1:
		return
	
	variable_value += 1
	
	current_data["variable_value"] = variable_value
	current_data["process_time"] = max(0.5, current_data["process_time"] * 0.95)
	current_data["success_chance"] = max(0.1, current_data["success_chance"] - 0.1)
	
	# Сохраняем изменения обратно в массив
	building_data[current_index] = current_data
	_update_ui()


# --- НАЖАТИЕ НА КНОПКУ УМЕНЬШЕНИЯ ---
func _on_down_pressed():
	if current_index == -1 or variable_value <= 0:
		return
	
	variable_value -= 1
	
	current_data["variable_value"] = variable_value
	current_data["process_time"] *= 1.05
	current_data["success_chance"] = min(1.0, current_data["success_chance"] + 0.1)
	
	# Сохраняем изменения обратно в массив
	building_data[current_index] = current_data
	_update_ui()


# --- ОБНОВЛЕНИЕ ТЕКСТОВ ---
func _update_ui():
	variable.text = str(variable_value)
	production_speed.text = "Время: " + str(round(current_data["process_time"])) + " сек"
	success_chance.text = "Шанс успеха: " + str(round(current_data["success_chance"] * 100)) + "%"


func _input(event):
	if event.is_action_pressed("hide_menu"):
		hide()
