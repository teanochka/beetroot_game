extends StaticBody2D

var building_key: String
var building_level: int = 1
var direction: Vector2 = Vector2.RIGHT

func _ready():
	# Можно добавить анимацию появления
	scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)

func setup(key: String, tex: Texture2D):
	building_key = key
	$Sprite2D.texture = tex
	
	# Настраиваем коллизию под размер спрайта
	var collision = $CollisionShape2D
	if collision and collision.shape is RectangleShape2D:
		var texture_size = tex.get_size()
		collision.shape.size = texture_size

# Можно добавить функции улучшения и т.д.
func upgrade():
	building_level += 1
	# Логика улучшения
