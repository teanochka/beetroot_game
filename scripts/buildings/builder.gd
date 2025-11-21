extends Node2D
var available_color : Color = Color.GREEN
var taken_color : Color = Color.RED
var alpha = 128
@onready var buildable_conveyor: Buildable = $BuildableConveyor
@onready var buildable_splitter: Buildable = $BuildableSplitter
@onready var buildable_building: Buildable = $BuildableBuilding
@onready var audio_controller: Node = $"../AudioController"
var current_buildable: Buildable
var current_data: BuildingData
var last_location: Vector2
var is_building_mode: bool = false
var follow_cursor:bool = true
var top_boundary: int = -48

func _ready():
	available_color.a = alpha
	taken_color.a = alpha
	hide()
	modulate = available_color

func hide_all_ghosts():
	buildable_conveyor.hide()
	buildable_splitter.hide()
	buildable_building.hide()

func start_building(building_data: BuildingData):
	current_data = building_data
	if building_data.building_type == "conveyor":
		current_buildable = buildable_conveyor
	elif building_data.building_type == "splitter":
		current_buildable = buildable_splitter
	else:
		current_buildable = buildable_building
		buildable_building.setup_with_data(building_data)
	show()
	is_building_mode = true
	hide_all_ghosts()
	current_buildable.show()

func _physics_process(_delta):
	if not is_building_mode:
		return 	
	if follow_cursor:
		var pos = get_global_mouse_position()
		var location = Vector2(round(pos.x/Constants.grid_size), round(pos.y/Constants.grid_size)) * Constants.grid_size
		
		global_position = location
		if current_buildable.can_place(location) and location.y >= top_boundary:
			modulate = available_color
		else:
			modulate = taken_color
			
		if last_location == null:
			last_location = location
			
		if Input.is_action_just_pressed("rotate"):
			current_buildable.rotate_clockwise()
			EventBus.emit_task_completed("rotate")
		if Input.is_action_just_pressed("left_click"):
			if current_buildable.can_place(location) and location.y >= top_boundary:
				if $"../UI".try_buy_building(current_data.build_price):
					current_buildable.place(location)
					audio_controller.play_bought()
					EventBus.emit_task_completed(current_data.building_type)
					print(current_data.building_type)
		if Input.is_action_pressed("right_click") or Input.is_action_just_pressed("destruction"):
				finish_building()
			
func finish_building():
	is_building_mode = false
	hide()

func _on_ui_building_selected(building_data: BuildingData) -> void:
	start_building(building_data)
