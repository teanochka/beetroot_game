extends Node

# Сигналы для связи с другими системами
signal ui_state_changed(is_any_ui_visible: bool)
signal building_selected(building_data: BuildingData)
signal deconstruction_mode_toggled(is_active: bool)
signal conveyor_filters_updated(position: Vector2, whitelist: Array, blacklist: Array, mode: int)

# Ссылки на UI элементы
@onready var conveyor_ui: CanvasLayer = get_parent().get_node("ConveyorUI")
@onready var building_ui: CanvasLayer = get_parent().get_node("BuildingUI")
@onready var build_ui: CanvasLayer = get_parent().get_node("UI")

# Текущее состояние
var current_ui: CanvasLayer = null
var selected_conveyor_position: Vector2 = Vector2.ZERO
var is_deconstruction_mode: bool = false

# Флаги состояния
var is_any_ui_visible: bool = false:
	set(value):
		is_any_ui_visible = value
		ui_state_changed.emit(value)
		EventBus.is_ui_visible = value

# Константы для типов UI (опционально, для удобства)
enum UIType { NONE, CONVEYOR, BUILDING, BUILD_MENU }

func _ready():
	# Инициализация скрытого состояния
	conveyor_ui.visible = false
	building_ui.visible = false
	if build_ui.has_method("_hide_all_menus"):
		build_ui._hide_all_menus()
	
	# Подключаем сигналы от build_ui
	if build_ui.has_signal("building_selected"):
		build_ui.building_selected.connect(_on_building_selected)
	if build_ui.has_signal("deconstruction_started"):
		build_ui.deconstruction_started.connect(_on_deconstruction_started)
	if build_ui.has_signal("deconstruction_finished"):
		build_ui.deconstruction_finished.connect(_on_deconstruction_finished)

func _input(event: InputEvent):
	# ПКМ или ESC закрывает любое UI
	if Input.is_action_just_pressed("right_click") or Input.is_action_just_pressed("hide_menu"):
		close_all_ui()
		return
	
	# Toggle build menu (только если нет другого открытого UI)
	if Input.is_action_just_pressed("build_menu") and !is_any_ui_visible:
		toggle_build_menu()
		return
	
	# Toggle deconstruction mode (только если нет другого открытого UI)
	if Input.is_action_just_pressed("destruction") and !is_any_ui_visible:
		toggle_deconstruction_mode()
		return

func open_conveyor_ui(position: Vector2, building_data):
	"""Открыть UI конвейера (закрывает все остальные UI)"""
	# Закрыть все UI перед открытием нового
	close_all_ui()
	
	selected_conveyor_position = position
	conveyor_ui.visible = true
	if conveyor_ui.has_method("set_lists"):
		conveyor_ui.set_lists(building_data.whitelist, building_data.blacklist)
	current_ui = conveyor_ui
	is_any_ui_visible = true

func open_building_ui(building_type: String):
	"""Открыть UI конкретного здания (закрывает все остальные UI)"""
	# Закрыть все UI перед открытием нового
	close_all_ui()
	
	if building_ui.has_method("open_building_ui"):
		building_ui.open_building_ui(building_type)
		building_ui.visible = true
		current_ui = building_ui
		is_any_ui_visible = true

func toggle_build_menu():
	"""Переключить меню строительства"""
	if is_deconstruction_mode:
		exit_deconstruction_mode()
	
	# Если уже открыт build menu - закрыть его
	if current_ui == build_ui:
		close_all_ui()
		return
	
	# Закрыть все UI и открыть build menu
	close_all_ui()
	
	if build_ui.has_method("_toggle_build_menu"):
		build_ui._toggle_build_menu()
		current_ui = build_ui
		is_any_ui_visible = true

func toggle_deconstruction_mode():
	"""Переключить режим сноса"""
	if is_deconstruction_mode:
		exit_deconstruction_mode()
	else:
		enter_deconstruction_mode()

func enter_deconstruction_mode():
	"""Войти в режим сноса"""
	# Закрыть любое открытое UI
	close_all_ui()
	
	is_deconstruction_mode = true
	if build_ui.has_method("enter_deconstruction_mode"):
		build_ui.enter_deconstruction_mode()
	deconstruction_mode_toggled.emit(true)

func exit_deconstruction_mode():
	"""Выйти из режима сноса"""
	is_deconstruction_mode = false
	if build_ui.has_method("exit_deconstruction_mode"):
		build_ui.exit_deconstruction_mode()
	deconstruction_mode_toggled.emit(false)

func close_all_ui():
	"""Закрыть ВСЕ открытые UI"""
	# Сохранить фильтры конвейера если он был открыт
	if conveyor_ui.visible:
		save_conveyor_filters()
	
	# Скрыть все UI
	conveyor_ui.visible = false
	building_ui.visible = false
	if build_ui.has_method("_hide_all_menus"):
		build_ui._hide_all_menus()
	
	# Выйти из режима сноса если был активен
	if is_deconstruction_mode:
		exit_deconstruction_mode()
	
	# Сбросить состояние
	selected_conveyor_position = Vector2.ZERO
	current_ui = null
	is_any_ui_visible = false

func save_conveyor_filters():
	"""Сохранить фильтры конвейера перед закрытием"""
	if conveyor_ui.visible and selected_conveyor_position != Vector2.ZERO:
		if conveyor_ui.has_method("get_whitelist") and conveyor_ui.has_method("get_blacklist") and conveyor_ui.has_method("get_mode"):
			var whitelist = conveyor_ui.get_whitelist()
			var blacklist = conveyor_ui.get_blacklist()
			var mode = conveyor_ui.get_mode()
			
			conveyor_filters_updated.emit(
				selected_conveyor_position,
				whitelist,
				blacklist,
				mode
			)

func handle_building_click(grid_pos: Vector2):
	"""Обработать клик по зданию (только если нет открытого UI)"""
	if is_deconstruction_mode or is_any_ui_visible:
		return
	
	var building = BuildingCoordinator.get_building_at(grid_pos)
	if building != null and building.clickable:
		var building_type = building.building_data.building_type
		
		if building_type == "conveyor":
			open_conveyor_ui(grid_pos, building)
		elif building_type != "splitter":  # Для сплиттера не показываем UI
			open_building_ui(building_type)

# Сигналы от build_ui
func _on_building_selected(building_data: BuildingData):
	building_selected.emit(building_data)

func _on_deconstruction_started():
	is_deconstruction_mode = true

func _on_deconstruction_finished():
	is_deconstruction_mode = false
