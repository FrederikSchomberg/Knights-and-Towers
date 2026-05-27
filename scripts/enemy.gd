extends Node2D
class_name Enemy

const AssetTools = preload("res://scripts/asset_utils.gd")

signal died(reward: int, world_position: Vector2)
signal reached_castle(damage: int)

@export var max_hp: int = 60
@export var speed: float = 70.0
@export var reward: int = 15
@export var castle_damage: int = 1
@export var enemy_kind: String = "Goblin"

var hp: int
var path_points: Array[Vector2] = []
var path_index: int = 0
var alive: bool = true
var enemy_texture: Texture2D

func setup(points: Array[Vector2], p_hp: int, p_speed: float, p_reward: int, p_castle_damage: int, p_kind: String) -> void:
	path_points = points.duplicate()
	max_hp = p_hp
	hp = max_hp
	speed = p_speed
	reward = p_reward
	castle_damage = p_castle_damage
	enemy_kind = p_kind
	_load_enemy_texture()
	path_index = 0
	alive = true
	if path_points.size() > 0:
		global_position = path_points[0]
	queue_redraw()

func _ready() -> void:
	_load_enemy_texture()
	add_to_group("enemies")
	hp = max_hp
	z_index = 20


func _load_enemy_texture() -> void:
	var texture_path: String = "res://assets/game/enemy_goblin.png"
	if enemy_kind == "Bandit":
		texture_path = "res://assets/game/enemy_bandit.png"
	elif enemy_kind == "Ork":
		texture_path = "res://assets/game/enemy_ork.png"
	elif enemy_kind == "Boss":
		texture_path = "res://assets/game/enemy_boss.png"
	enemy_texture = AssetTools.load_texture(texture_path)

func _process(delta: float) -> void:
	if not alive or path_points.size() < 2:
		return

	if path_index >= path_points.size() - 1:
		_finish_path()
		return

	var target: Vector2 = path_points[path_index + 1]
	global_position = global_position.move_toward(target, speed * delta)

	if global_position.distance_to(target) <= 1.0:
		path_index += 1
		if path_index >= path_points.size() - 1:
			_finish_path()

func take_damage(amount: int) -> void:
	if not alive:
		return
	hp -= amount
	queue_redraw()
	if hp <= 0:
		alive = false
		died.emit(reward, global_position)
		queue_free()

func get_progress_score() -> float:
	# Für Zielauswahl: Gegner weiter vorne auf dem Weg bekommen Priorität.
	if path_points.size() < 2:
		return 0.0
	var score: float = float(path_index)
	if path_index < path_points.size() - 1:
		var current: Vector2 = path_points[path_index]
		var next_point: Vector2 = path_points[path_index + 1]
		var segment_length: float = maxf(current.distance_to(next_point), 1.0)
		score += current.distance_to(global_position) / segment_length
	return score

func _finish_path() -> void:
	if not alive:
		return
	alive = false
	reached_castle.emit(castle_damage)
	queue_free()

func _draw() -> void:
	if enemy_texture != null:
		var max_size: Vector2 = Vector2(66, 66)
		if enemy_kind == "Boss":
			max_size = Vector2(92, 92)
		AssetTools.draw_centered(self, enemy_texture, Vector2(0, -2), max_size)
	else:
		var body_color: Color = Color(0.28, 0.75, 0.28)
		if enemy_kind == "Ork":
			body_color = Color(0.18, 0.50, 0.20)
		elif enemy_kind == "Bandit":
			body_color = Color(0.50, 0.26, 0.14)
		elif enemy_kind == "Boss":
			body_color = Color(0.55, 0.15, 0.12)

		# Körper / Kopf im Tiny-Swords-artigen Mockup-Stil
		draw_circle(Vector2(0, 4), 14, body_color)
		draw_circle(Vector2(0, -10), 11, body_color.lightened(0.1))
		draw_circle(Vector2(-4, -12), 2, Color.BLACK)
		draw_circle(Vector2(4, -12), 2, Color.BLACK)
		draw_rect(Rect2(Vector2(-10, 15), Vector2(20, 7)), Color(0.16, 0.10, 0.06))

	# HP-Bar
	var bar_width: float = 34.0
	var ratio: float = clampf(float(hp) / float(max_hp), 0.0, 1.0)
	draw_rect(Rect2(Vector2(-bar_width / 2.0, -32), Vector2(bar_width, 5)), Color(0.10, 0.04, 0.04))
	draw_rect(Rect2(Vector2(-bar_width / 2.0, -32), Vector2(bar_width * ratio, 5)), Color(0.85, 0.15, 0.12))
