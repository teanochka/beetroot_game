# money_label.gd
extends Label

@export var shake_intensity: float = 10.0
@export var shake_duration: float = 0.3
@export var flash_duration: float = 0.3

var original_position: Vector2
var original_color: Color
var original_font_size: int

func _ready():
	original_position = position
	original_color = Color.WHITE

func update_display(amount: int):
	text = str(amount) + "₽"

func shake_and_flash():
	shake_display()
	flash_red()

func shake_display():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Встряска
	tween.tween_property(self, "position:x", original_position.x - shake_intensity * 0.5, shake_duration * 0.2)
	tween.tween_property(self, "position:x", original_position.x + shake_intensity, shake_duration * 0.4)
	tween.tween_property(self, "position:x", original_position.x - shake_intensity, shake_duration * 0.4)
	tween.tween_property(self, "position:x", original_position.x, shake_duration * 0.2)

func flash_red():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Мигание красным
	tween.tween_property(self, "theme_override_colors/font_color", Color.RED, flash_duration * 0.3)
	tween.tween_property(self, "theme_override_colors/font_color", original_color, flash_duration * 0.7)
