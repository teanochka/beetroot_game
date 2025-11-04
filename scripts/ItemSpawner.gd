extends Node2D

@export var spawn_interval := 2.0
@onready var items_container := $Items
@onready var timer := Timer.new()
@onready var item_scene := preload("res://scenes/item.tscn")

func _ready():
	print("ItemSpawner готов. items_container:", items_container)
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.timeout.connect(spawn_item)
	timer.start()

func spawn_item():
	print("ItemSpawner: создаём предмет...")
	var item = item_scene.instantiate()

	var start_y_offset = -200
	item.global_position = global_position + Vector2(0, start_y_offset)

	# добавляем предмет в контейнер или родителя
	if items_container:
		items_container.add_child(item)
	else:
		get_parent().add_child(item)
		print("⚠️ Items контейнер не найден, добавляем напрямую в родителя")

	print("✅ Предмет заспавнен на позиции:", item.global_position)

	# создаём плавное падение
	var tween = create_tween()
	tween.tween_property(item, "global_position", global_position, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	tween.finished.connect(func():
		item.on_fall_finished()
)
