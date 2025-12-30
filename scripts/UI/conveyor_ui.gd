extends CanvasLayer

@onready var whitelist_button: TextureButton = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Whitelist
@onready var blacklist_button: TextureButton = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Blacklist
@onready var item_list: GridContainer = $Panel/MarginContainer/VBoxContainer/GridContainer
@onready var mode_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Mode

var item_ui = preload("res://scenes/item_ui.tscn")
var current_mode = "whitelist"

var whitelist: Array[String] = []
var blacklist: Array[String] = []

var item_paths = [
	"res://resources/items/beetroot.tres",
	"res://resources/items/chips.tres",
	"res://resources/items/juice.tres",
	"res://resources/items/syrup.tres",
	"res://resources/items/wet_sugar.tres",
	"res://resources/items/packed_sugar.tres",
	"res://resources/items/rot.tres"
]

var loaded_items: Array[ItemData] = []

func _ready() -> void:
	load_items()
	populate_item_list()
	update_mode_display()
	visible = false
	
func hide_ui() -> void:
	visible = false

func load_items() -> void:
	loaded_items.clear()
	for path in item_paths:
		var item_data: ItemData = load(path)
		if item_data:
			loaded_items.append(item_data)
		else:
			print("Failed to load item: ", path)

func populate_item_list() -> void:
	for child in item_list.get_children():
		child.queue_free()
	
	for item_data in loaded_items:
		var item_instance = item_ui.instantiate()
		item_list.add_child(item_instance)
		
		var texture_rect = item_instance.get_node("MarginContainer/TextureRect")
		if texture_rect and item_data.texture:
			texture_rect.texture = item_data.texture
		
		item_instance.gui_input.connect(_on_item_ui_clicked.bind(item_instance, item_data.item_type))
		
		update_item_overlay(item_instance, item_data.item_type)

func update_item_overlay(item_ui_instance, item_type: String) -> void:
	if current_mode == "whitelist":
		if whitelist.has(item_type):
			item_ui_instance.show_green_overlay()
		else:
			item_ui_instance.hide_overlay()
	else:
		if blacklist.has(item_type):
			item_ui_instance.show_red_overlay()
		else:
			item_ui_instance.hide_overlay()

func _on_item_ui_clicked(event: InputEvent, item_ui_instance, item_type: String) -> void:
	if Input.is_action_just_pressed("left_click"):
		toggle_item_selection(item_type, item_ui_instance)

func toggle_item_selection(item_type: String, item_ui_instance) -> void:
	if current_mode == "whitelist":
		if whitelist.has(item_type):
			print("прячем оверлей")
			whitelist.erase(item_type)
			item_ui_instance.hide_overlay()
		else:
			whitelist.append(item_type)
			item_ui_instance.show_green_overlay()
	else: # blacklist
		if blacklist.has(item_type):
			blacklist.erase(item_type)
			item_ui_instance.hide_overlay()
		else:
			blacklist.append(item_type)
			item_ui_instance.show_red_overlay()
	
	print("Current ", current_mode, ": ", whitelist if current_mode == "whitelist" else blacklist)

func _on_whitelist_toggled(toggled_on: bool) -> void:
	if toggled_on:
		blacklist_button.button_pressed = false
		current_mode = "whitelist"
		update_mode_display()
		refresh_item_overlays()

func _on_blacklist_toggled(toggled_on: bool) -> void:
	if toggled_on:
		whitelist_button.button_pressed = false
		current_mode = "blacklist"
		update_mode_display()
		refresh_item_overlays()

func update_mode_display() -> void:
	mode_label.text = "Текущий режим: " + current_mode.capitalize()

func refresh_item_overlays() -> void:
	for i in range(loaded_items.size()):
		var item_ui_instance = item_list.get_child(i)
		var item_type = loaded_items[i].item_type
		update_item_overlay(item_ui_instance, item_type)

func get_current_list() -> Array[String]:
	return whitelist if current_mode == "whitelist" else blacklist

func get_whitelist() -> Array[String]:
	return whitelist.duplicate()

func get_blacklist() -> Array[String]:
	return blacklist.duplicate()
	
func get_mode() -> String:
	return current_mode

func set_lists(new_whitelist: Array[String], new_blacklist: Array[String]) -> void:
	whitelist = new_whitelist.duplicate()
	blacklist = new_blacklist.duplicate()
	refresh_item_overlays()
