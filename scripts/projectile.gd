extends Node2D
class_name Projectile

const AssetTools = preload("res://scripts/asset_utils.gd")

@export var speed: float = 420.0
@export var damage: int = 20
@export var hit_radius: float = 12.0
@export var projectile_texture_path: String = "res://assets/game/projectile_arrow.png"

var projectile_texture: Texture2D

var target: Node2D
var game: Node

func setup(p_target: Node2D, p_damage: int) -> void:
	projectile_texture = AssetTools.load_texture(projectile_texture_path)
	target = p_target
	damage = p_damage
	game = get_tree().get_first_node_in_group("game")
	z_index = 40

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	var direction: Vector2 = target.global_position - global_position
	var distance: float = direction.length()
	if distance <= hit_radius:
		_hit_target()
		return

	global_position += direction.normalized() * speed * delta
	rotation = direction.angle()

func _hit_target() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.call("take_damage", damage)
		if is_instance_valid(game) and game.has_method("spawn_hit_marker"):
			game.call("spawn_hit_marker", "-%d" % damage, target.global_position + Vector2(0, -30), Color(1.0, 0.86, 0.25))
	queue_free()

func _draw() -> void:
	if projectile_texture != null:
		AssetTools.draw_centered(self, projectile_texture, Vector2.ZERO, Vector2(32, 16))
		return

	# Pfeil/Schuss-Mockup
	draw_line(Vector2(-10, 0), Vector2(10, 0), Color(0.20, 0.10, 0.04), 4.0)
	draw_circle(Vector2(10, 0), 4, Color(0.95, 0.85, 0.45))
