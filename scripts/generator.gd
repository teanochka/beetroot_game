extends Node2D

var is_protected: bool = true
@onready var box_path = preload("res://scenes/item.tscn")
@onready var timer: Timer = $Timer
@export var directions : Array[Enums.Direction] = []

@export var generated_item_data: ItemData
var clickable: bool = false
func _ready():
	BuildingCoordinator.add_building(global_position, self)
	$DirectionController.set_directions(directions)
	

func _on_conveyor_detectors_inventory_found(inventory: ConveyorInventory):
	var item = $ConveyorInventory.offload_item()
	inventory.receive_item(item)
	timer.start()


func _on_timer_timeout():
	var box = box_path.instantiate()
	
	if generated_item_data and box.has_method("setup"):
		box.setup(generated_item_data)
	
	$ConveyorInventory.generate_item(box)
	$ConveyorDetectors.start_checking()


func _on_direction_controller_directions_changed(to_directions):
	$ConveyorDetectors.set_directions(to_directions)
