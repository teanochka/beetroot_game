extends CanvasLayer

@onready var task_container: VBoxContainer = $Panel/MarginContainer/ScrollContainer/TaskContainer
@onready var task_scene = preload("res://scenes/task.tscn") 
@onready var building_placer = $"../BuildingPlacer"

# Словарь с переводами продуктов
var product_names = {
	"raw": "сырая свекла",
	"chips": "свекольная мякоть", 
	"juice": "свекольный сок",
	"syrup": "сахарный сироп",
	"wet_sugar": "влажный сахар",
	"packed_sugar": "упакованный сахар"
}

var tasks = [
	{
		"text": "Откройте меню строительства с помощью B",
		"complete": false,
		"type": "open_menu"
	},
	{
		"text": "Постройте конвейер в указанной точке",
		"complete": false,
		"type": "build_conveyor"
	},
	{
		"text": "Разверните конвейер с помощью R",
		"complete": false,
		"type": "rotate_conveyor"
	},
	{
		"text": "Перейдите в режим сноса на Q и удалите постройку",
		"complete": false,
		"type": "delete_building"
	},
	{
		"text": "Постройте очистительную станцию. Станции выгружают предметы справа от себя. Поставьте конвейер с правой стороны, чтобы продукт не пропал",
		"complete": false,
		"building": "cleaner",
		"type": "build_cleaner"
	},
	{
		"text": "Кликните на постройку чтобы открыть ее настройки",
		"complete": false,
		"type": "open_building_ui"
	},
	{
		"text": "Продайте предметы, доведя их до экспортера (тоннель справа сверху) по конвейерам",
		"complete": false,
		"type": "sell_items"
	},
	{
		"text": "Постройте диффузор и переработайте %s в %s" % [product_names["chips"], product_names["juice"]],
		"complete": false,
		"building": "diffuser", 
		"product": "juice",
		"type": "build_diffuser"
	},
	{
		"text": "Постройте выпаривающий аппарат и получите %s из %s" % [product_names["syrup"], product_names["juice"]],
		"complete": false,
		"building": "evaporator",
		"product": "syrup",
		"type": "build_evaporator"
	},
	{
		"text": "Постройте кристаллизатор и создайте %s из %s" % [product_names["wet_sugar"], product_names["syrup"]],
		"complete": false,
		"building": "crystallizer",
		"product": "wet_sugar",
		"type": "build_crystallizer"
	},
	{
		"text": "Постройте упаковщик и получите готовый %s" % product_names["packed_sugar"],
		"complete": false,
		"building": "packer",
		"product": "packed_sugar",
		"type": "build_packer"
	},
	{
		"text": "Создайте полную производственную цепочку от сырья до упакованного сахара",
		"complete": false,
		"type": "complete_chain"
	}
]

var completed_tasks: int = 0
var current_task_index: int = 0

func _ready() -> void:
	if not task_container:
		task_container = find_child("TaskContainer", true, false)
		if task_container:
			print("Found TaskContainer by name")
		else:
			print("ERROR: TaskContainer not found by name either")
	
	await get_tree().process_frame
	render_tasks()
	# Добавляем в группу для легкого доступа из других скриптов
	add_to_group("Tutorial")
	render_tasks()

func render_tasks():
	# Очищаем контейнер перед отрисовкой
	for child in task_container.get_children():
		child.queue_free()
	
	# Показываем выполненные задания + текущее активное
	var tasks_to_show = completed_tasks + 1
	if tasks_to_show > tasks.size():
		tasks_to_show = tasks.size()
	
	for i in range(tasks_to_show):
		var task = tasks[i]
		var task_instance = task_scene.instantiate()
		task_container.add_child(task_instance)
		
		# Настраиваем текст и состояние задания
		task_instance.set_task_text(task.text)
		task_instance.set_completed(task.complete)
		

# Публичные методы для других скриптов
func complete_current_task():
	if completed_tasks < tasks.size():
		tasks[completed_tasks].complete = true
		completed_tasks += 1
		render_tasks()
		print("Задание выполнено! Текущий прогресс: ", completed_tasks, "/", tasks.size())

func complete_task_by_type(task_type: String):
	for i in range(tasks.size()):
		var task = tasks[i]
		if task.get("type") == task_type and not task.complete:
			# Если это следующее задание по порядку, просто выполняем его
			if i == completed_tasks:
				complete_current_task()
			# Если это задание из будущего, отмечаем его как выполненное
			elif i > completed_tasks:
				task.complete = true
				render_tasks()
			break

func complete_task_by_building(building_key: String):
	for i in range(tasks.size()):
		var task = tasks[i]
		if task.has("building") and task.building == building_key and not task.complete:
			if i == completed_tasks:
				complete_current_task()
			elif i > completed_tasks:
				task.complete = true
				render_tasks()
			break

func complete_task_by_product(product_key: String):
	for i in range(tasks.size()):
		var task = tasks[i]
		if task.has("product") and task.product == product_key and not task.complete:
			if i == completed_tasks:
				complete_current_task()
			elif i > completed_tasks:
				task.complete = true
				render_tasks()
			break

func _process(delta: float) -> void:
	pass
