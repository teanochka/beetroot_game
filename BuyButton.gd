extends Button

@export var building_price: int = 50
@export var building_name: String = "Мойка"

func _ready():
	text = "Купить за " + str(building_price) + "G"
	# Подключаем сигнал
	pressed.connect(_on_pressed)
	# Проверяем доступность
	check_affordability()

func check_affordability():
	var game_manager = $"../../../../../../.."
	disabled = !game_manager.can_afford(building_price)

func _on_pressed():
	var game_manager = $"../../../../../../.."
	if game_manager.purchase(building_price):
		print("Куплено: ", building_name)
	else:
		print("Недостаточно денег")
