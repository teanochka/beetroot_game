extends Node2D

signal item_sold(item_value: int)

@export var is_protected: bool = true
var to_direction: Enums.Direction = Enums.Direction.Up
var from_direction: Enums.Direction = Enums.Direction.Left
@export var directions: Array[Enums.Direction] = []
@onready var conveyor_inventory = $ConveyorInventory
var clickable: bool = false
func _ready():
	BuildingCoordinator.add_building(global_position, self)
	
	if directions.is_empty():
		directions = [Enums.Direction.Up]
	
	$DirectionController.set_directions(directions)

func determine_from_direction():
	from_direction = $FromDirectionController.get_from_direction(to_direction)

func update_to_direction(to_directions):
	to_direction = to_directions[0]
	determine_from_direction()

func _on_conveyor_inventory_item_held():
	print("Item received in exporter")
	
	var item = conveyor_inventory.offload_item()
	if item:
		sell_item(item)

func sell_item(item: Node2D):
	var item_data = item.get_item_data()
	if item_data:
		var sell_value = item_data.value
			
		item_sold.emit(sell_value)
		$"../Tutorial".complete_task("sell_item")	
		item.queue_free()
			
	else:
		print("No item data found")
		item.queue_free()

func _on_from_direction_controller_direction_changed():
	determine_from_direction()

func _on_direction_controller_directions_changed(to_directions: Array[Enums.Direction]):
	update_to_direction(to_directions)
