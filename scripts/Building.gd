extends Node2D
class_name Building

@export var building_data: BuildingData
@export var is_protected: bool = false
var to_direction: Enums.Direction = Enums.Direction.Right
var from_direction: Enums.Direction = Enums.Direction.Left
@export var directions : Array[Enums.Direction] = []
@onready var from_controller : FromDirectionController = $FromDirectionController
@onready var sprite = $Sprite2D
@onready var timer = $Timer
var is_processing: bool = false 

func determine_from_direction():
	from_direction = from_controller.get_from_direction(to_direction)

func _ready():
	BuildingCoordinator.add_building(global_position, self)
	
	if directions.is_empty():
		directions = [Enums.Direction.Right]
	
	$DirectionController.set_directions(directions)
	print("Building directions", directions)
	if building_data:
		if building_data.sprite and sprite:
			sprite.texture = building_data.sprite
			sprite.offset = Vector2(0, building_data.sprite_offset)
		if building_data.processing_time and timer:
			timer.wait_time = building_data.processing_time
		else: timer.wait_time = 5
		

func update_to_direction(to_directions):
	to_direction = to_directions[0]
	determine_from_direction()
	$ConveyorDetectors.set_directions(to_directions)

func _on_conveyor_inventory_item_held():
	if timer:
		is_processing = true
		print("Starting processing for ", timer.wait_time, " seconds")
		await get_tree().process_frame
		$ConveyorDetectors.checking = false
		
		timer.start()
	else:
		$ConveyorDetectors.start_checking()

func _on_timer_timeout():
	is_processing = false	
	$ConveyorDetectors.start_checking()

func transform_output_item(item: Node2D):
	if building_data.output_item_data:
		print("Transforming item to: ", building_data.output_item_data.item_type)
		item.change_item_data(building_data.output_item_data)

func _on_conveyor_detectors_inventory_found(inventory: ConveyorInventory):
	if not is_processing:
		var item = $ConveyorInventory.offload_item()
		if item:
			transform_output_item(item)
			print("Offloading item from building")
			inventory.receive_item(item)
	else:
		print("Still processing, cannot offload yet")

func _on_from_direction_controller_direction_changed():
	determine_from_direction()


func _on_direction_controller_directions_changed(to_directions: Array[Enums.Direction]):
	update_to_direction(to_directions)
