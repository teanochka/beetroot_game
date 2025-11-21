extends HBoxContainer

@onready var item_name: Label = $ItemInfo/ItemName
@onready var item_description: Label = $ItemInfo/ItemDescription
@onready var buy_button: Button = $ItemInfo/BuyButton
@onready var item_image: TextureRect = $ItemImage

signal building_pressed(building_data: BuildingData)
signal prevent_buildind
signal continue_building

var current_building_data: BuildingData

func setup(building_data: BuildingData):
	current_building_data = building_data
	
	item_name.text = building_data.building_name
	item_description.text = building_data.description
	buy_button.text = "Купить за " + str(building_data.build_price) + "₽"
	
	if building_data.sprite:
		item_image.texture = building_data.sprite
	
	if not buy_button.is_connected("pressed", _on_buy_button_pressed):
		buy_button.pressed.connect(_on_buy_button_pressed)

func _on_buy_button_pressed():
	if current_building_data:
		building_pressed.emit(current_building_data)

func set_affordability(can_afford: bool):
	buy_button.disabled = !can_afford

func get_building_price() -> int:
	return current_building_data.build_price if current_building_data else 0


func _on_buy_button_mouse_entered() -> void:
	prevent_buildind.emit()


func _on_buy_button_mouse_exited() -> void:
	continue_building.emit()


func _on_buy_button_focus_entered() -> void:
	prevent_buildind.emit()
