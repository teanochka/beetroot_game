extends Panel
@onready var image: TextureRect = $MarginContainer/TextureRect
@onready var overlay: Panel = $ColorOverlay

func _ready() -> void:
	hide_overlay()

func show_green_overlay() -> void:
	overlay.visible = true
	overlay.modulate = Color(0, 1, 0, 0.3)

func show_red_overlay() -> void:
	overlay.visible = true
	overlay.modulate = Color(1, 0, 0, 0.3)


func hide_overlay() -> void:
	overlay.visible = false
