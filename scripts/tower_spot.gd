extends Area2D
class_name TowerSpot

@export var build_cost: int = 50
var occupied: bool = false
var hovered: bool = false

func _ready() -> void:
	z_index = 5
	mouse_entered.connect(func() -> void:
		hovered = true
		queue_redraw()
	)
	mouse_exited.connect(func() -> void:
		hovered = false
		queue_redraw()
	)
	queue_redraw()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var game: Node = get_tree().get_first_node_in_group("game")
		if is_instance_valid(game) and game.has_method("try_build_tower"):
			game.call("try_build_tower", self)

func mark_occupied() -> void:
	occupied = true
	queue_redraw()

func _draw() -> void:
	var base_color: Color = Color(0.78, 0.68, 0.42, 0.85)
	if occupied:
		base_color = Color(0.25, 0.20, 0.12, 0.45)
	elif hovered:
		base_color = Color(0.95, 0.86, 0.42, 0.95)

	draw_circle(Vector2.ZERO, 26, Color(0.12, 0.08, 0.04, 0.25))
	draw_circle(Vector2.ZERO, 22, base_color)
	draw_arc(Vector2.ZERO, 22, 0.0, TAU, 32, Color(0.20, 0.12, 0.05), 2.0)
	if not occupied:
		draw_string(ThemeDB.fallback_font, Vector2(-17, 6), "%dG" % build_cost, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.13, 0.08, 0.03))
