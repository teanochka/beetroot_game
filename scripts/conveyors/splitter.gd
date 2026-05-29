extends Node2D

var to_directions: Array[Enums.Direction] = []
var from_direction: Enums.Direction = Enums.Direction.Right
@export var is_protected: bool = false
var building_data: BuildingData = preload("res://resources/buildings/splitter.tres")
@export var directions : Array[Enums.Direction] = []
@onready var sprite = $SplitterSpriteController
@onready var filter_icon: Sprite2D = $FilterIcon
var mode: String = "whitelist"
var whitelist: Array[String] = []
var blacklist: Array[String] = []
var clickable: bool = true

var item_path_map: Dictionary = {
	"beetroot": "res://resources/items/beetroot.tres",
	"chips": "res://resources/items/chips.tres",
	"juice": "res://resources/items/juice.tres",
	"syrup": "res://resources/items/syrup.tres",
	"wet_sugar": "res://resources/items/wet_sugar.tres",
	"packed_sugar": "res://resources/items/packed_sugar.tres",
	"rot": "res://resources/items/rot.tres"
}

func determine_from_direction():
	for direction in Enums.Direction.values():
		if not to_directions.has(direction):
			from_direction = direction

func set_direction():
	sprite.set_sprite_frame(from_direction)

func _ready():
	BuildingCoordinator.add_building(global_position, self)
	self.add_to_group("conveyors")
	$DirectionController.set_directions(directions)

func update_to_direction(new_directions: Array[Enums.Direction]):
	to_directions = new_directions
	determine_from_direction()
	set_direction()
	$ConveyorDetectors.set_directions(new_directions)


func _on_conveyor_detectors_inventory_found(inventory: ConveyorInventory):
	var item = $ConveyorInventory.offload_item()
	if item:
		inventory.receive_item(item)

func _on_conveyor_inventory_item_held():
	$ConveyorDetectors.start_checking()

func _on_from_direction_controller_direction_changed():
	determine_from_direction()
	set_direction()

func _on_direction_controller_directions_changed(new_directions: Array[Enums.Direction]):
	update_to_direction(new_directions)

func can_accept_item_type(item: Node2D) -> bool:
	if not building_data or building_data.input_resource_type.is_empty():
		return check_item_filters(item)

	if item.has_method("get_item_type"):
		var item_type = item.get_item_type()
		if building_data.input_resource_type.has(item_type):
			return check_item_filters(item)

	return false

func check_item_filters(item: Node2D) -> bool:
	if not item.has_method("get_item_type"):
		return true

	var item_type = item.get_item_type()

	if mode == "whitelist":
		if whitelist.size() > 0:
			return whitelist.has(item_type)
		else:
			return true
	else:
		if blacklist.size() > 0:
			return not blacklist.has(item_type)
		else:
			return true

func update_filter_display():
	if not filter_icon:
		filter_icon = get_node_or_null("FilterIcon")
		if not filter_icon:
			print("FilterIcon node not found!")
			return

	var active_list = whitelist if mode == "whitelist" else blacklist

	if active_list.size() > 0:
		var first_item_type = active_list[0]
		var item_data = load_item_data(first_item_type)

		if item_data and item_data.texture:
			filter_icon.texture = item_data.texture
			filter_icon.visible = true

			if mode == "whitelist":
				filter_icon.modulate = Color(0.5, 1, 0.5)
			else:
				filter_icon.modulate = Color(1, 0.5, 0.5)
		else:
			filter_icon.visible = false
			print("Failed to load texture for item type: ", first_item_type)
	else:
		filter_icon.visible = false

func load_item_data(item_type: String) -> ItemData:
	if item_path_map.has(item_type):
		var path = item_path_map[item_type]
		var item_data: ItemData = load(path)
		return item_data
	else:
		print("Unknown item type: ", item_type)
		return null


func _on_inventory_found() -> void:
	pass # Replace with function body.
