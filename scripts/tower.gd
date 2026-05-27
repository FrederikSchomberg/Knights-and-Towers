extends Node2D
class_name Tower

const AssetTools = preload("res://scripts/asset_utils.gd")

@export var attack_range: float = 185.0
@export var damage: int = 24
@export var attacks_per_second: float = 1.05
@export var tower_name: String = "Archer Tower"
@export var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
@export var tower_texture_path: String = "res://assets/game/tower_archer.png"

var tower_texture: Texture2D

var attack_timer: Timer
var game: Node

func _ready() -> void:
	tower_texture = AssetTools.load_texture(tower_texture_path)
	add_to_group("towers")
	game = get_tree().get_first_node_in_group("game")
	z_index = 10
	attack_timer = Timer.new()
	attack_timer.wait_time = 1.0 / maxf(attacks_per_second, 0.1)
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_try_attack)
	add_child(attack_timer)
	attack_timer.start()
	queue_redraw()

func _try_attack() -> void:
	var target: Enemy = _get_best_target()
	if target == null:
		return

	var projectile: Projectile = projectile_scene.instantiate() as Projectile
	projectile.global_position = global_position + Vector2(0, -18)
	var projectile_parent: Node = get_tree().get_first_node_in_group("projectiles_layer")
	if projectile_parent == null:
		get_tree().current_scene.add_child(projectile)
	else:
		projectile_parent.add_child(projectile)
	projectile.setup(target, damage)

func _get_best_target() -> Enemy:
	var best: Enemy = null
	var best_score: float = -9999.0
	for enemy_object in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy_object):
			continue
		var enemy: Enemy = enemy_object as Enemy
		if enemy == null:
			continue
		if global_position.distance_to(enemy.global_position) > attack_range:
			continue
		var score: float = enemy.get_progress_score()
		if score > best_score:
			best_score = score
			best = enemy
	return best

func _draw() -> void:
	# Reichweite als dezenter Kreis
	draw_circle(Vector2.ZERO, attack_range, Color(0.95, 0.95, 1.0, 0.06))
	draw_arc(Vector2.ZERO, attack_range, 0.0, TAU, 64, Color(0.90, 0.90, 1.0, 0.17), 2.0)

	if tower_texture != null:
		AssetTools.draw_centered(self, tower_texture, Vector2(0, -10), Vector2(92, 92))
		return

	# Turm-Mockup
	draw_rect(Rect2(Vector2(-22, -10), Vector2(44, 42)), Color(0.44, 0.27, 0.12))
	draw_rect(Rect2(Vector2(-28, -28), Vector2(56, 26)), Color(0.54, 0.34, 0.16))
	draw_rect(Rect2(Vector2(-18, -44), Vector2(36, 18)), Color(0.39, 0.39, 0.42))
	draw_circle(Vector2(0, -30), 8, Color(0.16, 0.12, 0.08))
	draw_line(Vector2(0, -30), Vector2(24, -38), Color(0.15, 0.08, 0.03), 4.0)
