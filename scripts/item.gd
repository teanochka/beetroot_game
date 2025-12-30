extends Node2D
class_name Item

@export var item_data: ItemData
@onready var sprite = $Sprite2D

var is_beetroot: bool = false
var rotting_stage: int = 0
var rotting_timer: Timer
var rotting_texture: Texture2D
var original_texture: Texture2D
const ROTTING_TIME: float = 20.0
const MAX_ROTTING_STAGE: int = 3

func _ready():
	EventBus.emit_task_completed(item_data.item_type)
	
	if item_data and item_data.texture:
		if sprite:
			sprite.texture = item_data.texture
			original_texture = item_data.texture
	
	init_rotting()

func setup(data: ItemData):
	item_data = data
	_ready()

func get_item_type() -> String:
	return item_data.item_type if item_data else "unknown"

func change_item_data(new_data: ItemData):
	if is_beetroot and rotting_timer:
		rotting_timer.stop()
		rotting_timer.queue_free()
	
	item_data = new_data
	if sprite:
		sprite.region_enabled = false
	
	# Также сбрасываем состояние свеклы
	is_beetroot = false
	rotting_stage = 0
	_ready()

func get_item_data() -> ItemData:
	return item_data

func init_rotting():
	if item_data and item_data.item_type == "beetroot":
		is_beetroot = true
		rotting_stage = 0
		
		rotting_texture = load("res://assets/beetroot_rotting.png")
		
		if rotting_texture:
			print("Beetroot rotting system initialized")
			
			rotting_timer = Timer.new()
			rotting_timer.wait_time = ROTTING_TIME
			rotting_timer.one_shot = false
			rotting_timer.timeout.connect(_on_rotting_timer_timeout)
			add_child(rotting_timer)
			
			rotting_timer.start()
			update_rotting_sprite()
		else:
			print("ERROR: Beetroot rotting texture not found")

func update_rotting_sprite():
	if not is_beetroot or not rotting_texture or not sprite:
		return
	
	sprite.texture = rotting_texture
	
	var texture_size = rotting_texture.get_size()
	var frame_width = texture_size.x / 4
	
	var region = Rect2(frame_width * rotting_stage, 0, frame_width, texture_size.y)
	sprite.region_rect = region
	sprite.region_enabled = true

func _on_rotting_timer_timeout():
	if is_beetroot:
		rotting_stage = min(rotting_stage + 1, MAX_ROTTING_STAGE)
		
		update_rotting_sprite()
		
		if rotting_stage >= MAX_ROTTING_STAGE:
			var rot_data = load("res://resources/items/rot.tres")
			if rot_data:
				change_item_data(rot_data)
				print("Beetroot fully rotted, changed to rot")
			stop_rotting()

func stop_rotting():
	if is_beetroot and rotting_timer:
		rotting_timer.stop()

func _exit_tree():
	if rotting_timer and rotting_timer.is_inside_tree():
		rotting_timer.queue_free()
