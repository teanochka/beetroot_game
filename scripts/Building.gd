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
@onready var progress_bar: Node2D = $ProgressBar
var is_processing: bool = false 
var clickable: bool = true

# Добавляем переменные для анимации
var is_animated: bool = false
var frame_count: int = 16
var current_frame: int = 0
var animation_timer: Timer
var animation_speed: float = 0.1 
var frame_width: float = 0  # Добавляем переменную для ширины кадра

func determine_from_direction():
	from_direction = from_controller.get_from_direction(to_direction)

func _ready():
	BuildingCoordinator.add_building(global_position, self)
	
	if directions.is_empty():
		directions = [Enums.Direction.Right]
	
	$DirectionController.set_directions(directions)
	print("Building directions", directions)
	
	if building_data:
		# Сначала устанавливаем обычный спрайт
		if building_data.sprite and sprite:
			sprite.texture = building_data.sprite
			sprite.offset = Vector2(0, building_data.sprite_offset)
		
		# Затем настраиваем анимацию, если есть
		if building_data.animation and building_data.frames != 0:
			is_animated = true
			frame_count = building_data.frames
			
			# Устанавливаем анимированный спрайтшит
			sprite.texture = building_data.animation
			sprite.region_enabled = true
			
			# Вычисляем ширину кадра
			if sprite.texture:
				var texture_size = sprite.texture.get_size()
				frame_width = texture_size.x / frame_count
				print("Animation texture size: ", texture_size, ", frame width: ", frame_width, ", frames: ", frame_count)
			
			# Устанавливаем первый кадр
			set_sprite_frame(0)
			
			# Создаем таймер анимации
			animation_timer = Timer.new()
			animation_timer.wait_time = animation_speed
			animation_timer.one_shot = false
			animation_timer.timeout.connect(_on_animation_timer_timeout)
			add_child(animation_timer)
		
		# Настраиваем таймер обработки
		if building_data.processing_time and timer:
			timer.wait_time = building_data.processing_time
		else: 
			timer.wait_time = 5
	
	progress_bar.hide()

func _process(_delta):
	if is_processing and timer and progress_bar:
		var progress = 1.0 - (timer.time_left / timer.wait_time)
		progress_bar.update_progress(progress * 100)

func update_to_direction(to_directions):
	to_direction = to_directions[0]
	determine_from_direction()
	$ConveyorDetectors.set_directions(to_directions)

func _on_conveyor_inventory_item_held():
	if timer:
		is_processing = true
		print("Starting processing for ", timer.wait_time, " seconds")
		
		# Запускаем анимацию
		if is_animated and animation_timer:
			animation_timer.start()
			print("Animation started for ", building_data.building_type)
		
		progress_bar.show()
		progress_bar.update_progress(0)
		
		await get_tree().process_frame
		$ConveyorDetectors.checking = false
		
		timer.start()
	else:
		$ConveyorDetectors.start_checking()

func can_accept_item_type(item: Node2D) -> bool:
	if not building_data or building_data.input_resource_type.is_empty():
		return true 
	
	if item.has_method("get_item_type"):
		var item_type = item.get_item_type()
		return building_data.input_resource_type.has(item_type)
	
	return false

func _on_timer_timeout():
	is_processing = false	
	progress_bar.hide()
	progress_bar.update_progress(0)
	
	# Останавливаем анимацию
	if is_animated and animation_timer:
		animation_timer.stop()
		# Возвращаемся к первому кадру
		set_sprite_frame(0)
		print("Animation stopped for ", building_data.building_type)
	
	var item = $ConveyorInventory.peek_item()
	if item:
		transform_output_item(item)
	$ConveyorDetectors.start_checking()

func transform_output_item(item: Node2D):
	if building_data.output_item_data:
		print("Transforming item to: ", building_data.output_item_data.item_type)
		item.change_item_data(building_data.output_item_data)

func _on_conveyor_detectors_inventory_found(inventory: ConveyorInventory):
	if not is_processing:
		var item = $ConveyorInventory.offload_item()
		if item:
			print("Offloading item from building")
			inventory.receive_item(item)
	else:
		print("Still processing, cannot offload yet")

func _on_from_direction_controller_direction_changed():
	determine_from_direction()

func _on_direction_controller_directions_changed(to_directions: Array[Enums.Direction]):
	update_to_direction(to_directions)
	
func set_sprite_frame(frame_index: int):
	if not is_animated or not sprite.texture:
		return
	
	current_frame = frame_index % frame_count
	
	# Создаем region_rect для выбора кадра
	var region = Rect2(frame_width * current_frame, 0, frame_width, sprite.texture.get_size().y)
	sprite.region_rect = region
	
	# Для отладки
	#print("Set frame ", current_frame, ", region: ", region)
	
func _on_animation_timer_timeout():
	if is_processing and is_animated:
		current_frame = (current_frame + 1) % frame_count
		set_sprite_frame(current_frame)

# Очистка при удалении
func _exit_tree():
	if animation_timer and animation_timer.is_inside_tree():
		animation_timer.queue_free()
