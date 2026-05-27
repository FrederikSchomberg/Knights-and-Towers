extends CharacterBody2D
class_name Player

const AssetTools = preload("res://scripts/asset_utils.gd")

@export var move_speed: float = 190.0
@export var attack_range: float = 70.0
@export var attack_damage: int = 18
@export var attack_cooldown: float = 0.42
@export var player_texture_path: String = "res://assets/game/player.png"

var player_texture: Texture2D

var cooldown_left: float = 0.0
var facing: Vector2 = Vector2.RIGHT

func _ready() -> void:
	player_texture = AssetTools.load_texture(player_texture_path)
	add_to_group("player")
	z_index = 30
	queue_redraw()

func _physics_process(delta: float) -> void:
	cooldown_left = maxf(cooldown_left - delta, 0.0)
	var input_vector: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0

	if input_vector.length() > 0.0:
		facing = input_vector.normalized()
	velocity = input_vector.normalized() * move_speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_attack()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_attack()

func _attack() -> void:
	if cooldown_left > 0.0:
		return
	cooldown_left = attack_cooldown

	var target: Enemy = _find_nearest_enemy()
	var game: Node = get_tree().get_first_node_in_group("game")
	if target != null:
		target.take_damage(attack_damage)
		if is_instance_valid(game) and game.has_method("spawn_hit_marker"):
			game.call("spawn_hit_marker", "HIT -%d" % attack_damage, target.global_position + Vector2(0, -42), Color(1.0, 0.95, 0.35))
	else:
		if is_instance_valid(game) and game.has_method("spawn_hit_marker"):
			game.call("spawn_hit_marker", "miss", global_position + facing * 42 + Vector2(0, -18), Color(0.9, 0.9, 0.9))

	queue_redraw()

func _find_nearest_enemy() -> Enemy:
	var best: Enemy = null
	var best_dist: float = INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var enemy_node: Enemy = enemy as Enemy
		if enemy_node == null:
			continue
		var dist: float = global_position.distance_to(enemy_node.global_position)
		if dist <= attack_range and dist < best_dist:
			best = enemy_node
			best_dist = dist
	return best

func _draw() -> void:
	draw_circle(Vector2.ZERO, attack_range, Color(0.9, 0.9, 1.0, 0.055))
	if player_texture != null:
		AssetTools.draw_centered(self, player_texture, Vector2(0, -4), Vector2(72, 72))
		return

	# Player/King/Ritter als Mockup. Später durch Tiny-Swords/Kenney-Sprite ersetzen.
	draw_circle(Vector2(0, 5), 15, Color(0.18, 0.28, 0.80))
	draw_circle(Vector2(0, -12), 12, Color(0.98, 0.78, 0.52))
	draw_rect(Rect2(Vector2(-11, -25), Vector2(22, 6)), Color(0.94, 0.78, 0.18))
	draw_rect(Rect2(Vector2(-7, -32), Vector2(14, 8)), Color(0.94, 0.78, 0.18))
	draw_line(Vector2(12, 2), Vector2(30, -12), Color(0.82, 0.82, 0.86), 5.0)
