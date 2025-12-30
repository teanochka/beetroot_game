extends Area2D
class_name ConveyorInventory
var moving_item = false
@export var speed: int = 70
signal item_held

var holder: Node2D
func _ready():
	holder = Node2D.new()
	add_child(holder)

func can_receive_item(item: Node2D = null) -> bool:
	if item == null:
		return holder.get_child_count() == 0
	
	var building = get_parent()
	if building and building.has_method("can_accept_item_type"):
		return building.can_accept_item_type(item) and holder.get_child_count() == 0
	
	return holder.get_child_count() == 0

func generate_item(item: Node2D):
	holder.add_child(item)
	moving_item = true

func receive_item(item: Node2D):
	item.reparent(holder, true)
	moving_item = true

func offload_item():
	var item = holder.get_child(0)
	return item

func peek_item() -> Node2D:
	if holder.get_child_count() == 0:
		return null
	return holder.get_child(0)

func hold_item():
	moving_item = false
	emit_signal("item_held")

func _physics_process(delta):
	if not moving_item or holder.get_child_count() == 0:
		return
	var item = holder.get_child(0)
	if item is Node2D:
		item.global_position = item.global_position.move_toward(global_position, speed * delta)
		if item.global_position == global_position:
			hold_item()
