extends Area2D

@export var speed := 40.0
@onready var sprite := $Sprite2D
var current_cell: Vector2i
var map: TileMap  # ссылка на твой TileMap

func _physics_process(delta):
	if map == null:
		return
	
	# Получаем клетку под предметом
	var cell = map.local_to_map(map.to_local(global_position))
	current_cell = cell
	
	# Проверяем, есть ли постройка под предметом
	if map.has_meta("occupied_cells"):  # если хранишь словарь на TileMap
		var data = map.get_meta("occupied_cells")
		if data.has(cell):
			var btype = data[cell]
			match btype:
				"conveyor":
					move_on_conveyor(delta)
				"washer":
					process_in_washer()
				_:  # другие типы
					pass

func move_on_conveyor(delta):
	global_position += Vector2.RIGHT * speed * delta

func process_in_washer():
	# здесь можно сделать логику "исчез на 10 секунд, потом вернуть"
	queue_free()
