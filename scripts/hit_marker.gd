extends Label
class_name HitMarker

@export var lifetime: float = 0.65
var age: float = 0.0
var start_position: Vector2

func setup(p_text: String, p_color: Color) -> void:
	text = p_text
	modulate = p_color
	add_theme_font_size_override("font_size", 18)
	add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	add_theme_constant_override("outline_size", 3)
	start_position = position
	z_index = 100

func _process(delta: float) -> void:
	age += delta
	position = start_position + Vector2(0, -34.0 * age)
	var alpha: float = 1.0 - clampf(age / lifetime, 0.0, 1.0)
	modulate.a = alpha
	if age >= lifetime:
		queue_free()
