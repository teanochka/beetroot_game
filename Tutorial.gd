extends CanvasLayer

@onready var task_container: VBoxContainer = $Panel/MarginContainer/ScrollContainer/TaskContainer
@onready var task_scene = preload("res://scenes/task.tscn") 
@onready var scroll_container: ScrollContainer = $Panel/MarginContainer/ScrollContainer
var completed_tasks: Array[String] = []  # Храним типы выполненных заданий
var current_task_type: String = ""  # Текущий активный квест

var tasks = [
	{
		"text": "Откройте меню строительства с помощью B",
		"type": "build_menu"
	},
	{
		"text": "Выберите конвейер",
		"type": "select_conveyor"
	},
	{
		"text": "Разверните конвейер с помощью R",
		"type": "rotate"
	},
	{
		"text": "Постройте конвейер",
		"type": "conveyor"
	},
	{
		"text": "Постройте очистительную станцию",
		"type": "cleaner"
	},
	{
		"text": "Произведите свекольную мякоть с помощью очистительной станции",
		"type": "chips"
	},
	{
		"text": "Видите тоннель в стене справа сверху? Это экспортер. Доведите до него предмет, чтобы он продался.",
		"type": "sell_item"
	},
	{
		"text": "Перейдите в режим сноса на Q и удалите любую постройку, нажав на неё ЛКМ",
		"type": "delete_building"
	},
	{
		"text": "Постройте диффузор",
		"type": "diffuser"
	},
	{
		"text": "Произведите свекольный сок из свекольной мякоти с помощью диффузора",
		"type": "juice"
	},
	{
		"text": "Следующая постройка слишком дорогая. Давайте увеличим наши доходы - постройте разделитель, чтобы вести свеклу по нескольким линиям",
		"type": "splitter"
	},
	{
		"text": "Постройте выпаривающий аппарат",
		"type": "evaporator"
	},
	{
		"text": "Произведите сахарный сироп из свекольного сока с помощью выпаривающего апарата",
		"type": "syrup"
	},
	{
		"text": "Постройте кристаллизатор",
		"type": "crystallizer"
	},
	{
		"text": "Произведите влажный сахар из сахарного сиропа",
		"type": "wet_sugar"
	},
	{
		"text": "Постройте упаковщик",
		"type": "packer"
	},
	{
		"text": "Произведите упакованный сахар",
		"type": "packed_sugar"
	},
]

func _ready() -> void:
	EventBus.tutorial_task_completed.connect(complete_task)
	update_current_task()
	render_tasks()

func render_tasks():
	for child in task_container.get_children():
		child.queue_free()
	
	var next_task_index = get_next_task_index()
	var tasks_to_show = next_task_index + 1
	if tasks_to_show > tasks.size():
		tasks_to_show = tasks.size()
	
	for i in range(tasks_to_show):
		var task = tasks[i]
		var task_instance = task_scene.instantiate()
		task_container.add_child(task_instance)
		
		var is_completed = is_task_completed(task.type)
		task_instance.set_task_text(task.text)
		task_instance.set_completed(is_completed)
	
	update_current_task()
	scroll_to_bottom()

func scroll_to_bottom():
	await get_tree().process_frame
	var v_scroll_bar = scroll_container.get_v_scroll_bar()
	if v_scroll_bar:
		scroll_container.scroll_vertical = v_scroll_bar.max_value

func is_task_completed(task_type: String) -> bool:
	return completed_tasks.has(task_type)

func get_next_task_index() -> int:
	for i in range(tasks.size()):
		if not is_task_completed(tasks[i].type):
			return i
	return tasks.size()

func update_current_task():
	var previous_task = current_task_type
	var next_task_index = get_next_task_index()
	
	if next_task_index < tasks.size():
		current_task_type = tasks[next_task_index].type
	else:
		current_task_type = ""
	
	if current_task_type != previous_task:
		EventBus.emit_current_task_changed(current_task_type)
		print("Текущий квест изменен: ", current_task_type)

func complete_task(task_type: String):
	if is_task_completed(task_type):
		return
	
	completed_tasks.append(task_type)
	
	print("Задание выполнено: ", task_type)
	print("Выполнено заданий: ", completed_tasks.size(), "/", tasks.size())
	
	render_tasks()

func is_current_task(task_type: String) -> bool:
	return current_task_type == task_type
