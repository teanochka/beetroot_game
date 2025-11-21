extends Node2D
class_name Item
@export var item_data: ItemData

func _ready():
	EventBus.emit_task_completed(item_data.item_type)
	if item_data.texture:
		var sprite = $Sprite2D
		if sprite:
			sprite.texture = item_data.texture

func setup(data: ItemData):
	item_data = data
	_ready()

func get_item_type() -> String:
	return item_data.item_type if item_data else "unknown"

func change_item_data(new_data: ItemData):
	item_data = new_data
	_ready()

func get_item_data() -> ItemData:
	return item_data
