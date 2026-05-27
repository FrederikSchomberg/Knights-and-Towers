extends Node2D
class_name GameMap

const AssetTools = preload("res://scripts/asset_utils.gd")

var path_points: Array[Vector2] = []
var grass_texture: Texture2D
var castle_texture: Texture2D
var tree_texture: Texture2D
var rock_texture: Texture2D

func _ready() -> void:
	grass_texture = AssetTools.load_texture("res://assets/game/grass_tile.png")
	castle_texture = AssetTools.load_texture("res://assets/game/castle.png")
	tree_texture = AssetTools.load_texture("res://assets/game/tree.png")
	rock_texture = AssetTools.load_texture("res://assets/game/rock.png")

func set_path_points(points: Array[Vector2]) -> void:
	path_points = points
	queue_redraw()

func _draw() -> void:
	# Mockup-Map: Gras, Weg, Spawn, Burg und Deko.
	if grass_texture != null:
		draw_texture_rect(grass_texture, Rect2(Vector2.ZERO, Vector2(1280, 720)), true)
	else:
		draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.31, 0.58, 0.30))

	# leichte Kachelandeutung im 64x64-Raster passend zu Tiny Swords
	for x in range(0, 1280, 64):
		for y in range(0, 720, 64):
			var tint: Color = Color(1, 1, 1, 0.035) if int((x / 64 + y / 64)) % 2 == 0 else Color(0, 0, 0, 0.025)
			draw_rect(Rect2(Vector2(x, y), Vector2(64, 64)), tint)

	if path_points.size() >= 2:
		var packed_path: PackedVector2Array = PackedVector2Array(path_points)
		# Schatten unter dem Weg
		draw_polyline(packed_path, Color(0.19, 0.14, 0.10, 0.45), 58.0, true)
		# Hauptweg
		draw_polyline(packed_path, Color(0.68, 0.53, 0.33), 48.0, true)
		# hellere Mitte
		draw_polyline(packed_path, Color(0.78, 0.64, 0.42), 26.0, true)

		# runde Kappen an Kurvenpunkten
		for p in path_points:
			draw_circle(p, 24.0, Color(0.78, 0.64, 0.42))

		# Spawn-Markierung
		draw_circle(path_points[0], 26.0, Color(0.35, 0.18, 0.18))
		draw_string(ThemeDB.fallback_font, path_points[0] + Vector2(-35, -36), "Spawn", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

		# Burg am Ende
		var castle_pos: Vector2 = path_points[path_points.size() - 1]
		if castle_texture != null:
			AssetTools.draw_centered(self, castle_texture, castle_pos + Vector2(0, -30), Vector2(150, 150))
		else:
			draw_rect(Rect2(castle_pos + Vector2(-58, -70), Vector2(116, 92)), Color(0.48, 0.48, 0.50))
			draw_rect(Rect2(castle_pos + Vector2(-72, -88), Vector2(34, 110)), Color(0.39, 0.39, 0.42))
			draw_rect(Rect2(castle_pos + Vector2(38, -88), Vector2(34, 110)), Color(0.39, 0.39, 0.42))
			draw_rect(Rect2(castle_pos + Vector2(-18, -24), Vector2(36, 46)), Color(0.20, 0.12, 0.07))
		draw_string(ThemeDB.fallback_font, castle_pos + Vector2(-28, 42), "Burg", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)

	# Deko-Bäume und Steine als Mockup oder Drop-in-Sprites
	var tree_positions: Array[Vector2] = [Vector2(150, 90), Vector2(220, 580), Vector2(950, 120), Vector2(1110, 590), Vector2(520, 90), Vector2(760, 620)]
	for tree in tree_positions:
		if tree_texture != null:
			AssetTools.draw_centered(self, tree_texture, tree, Vector2(72, 72))
		else:
			draw_rect(Rect2(tree + Vector2(-5, 8), Vector2(10, 24)), Color(0.34, 0.20, 0.10))
			draw_circle(tree, 22, Color(0.12, 0.38, 0.16))
			draw_circle(tree + Vector2(-14, 10), 16, Color(0.09, 0.32, 0.12))
			draw_circle(tree + Vector2(14, 9), 16, Color(0.10, 0.34, 0.14))

	var rock_positions: Array[Vector2] = [Vector2(360, 640), Vector2(1030, 340), Vector2(90, 420), Vector2(700, 150)]
	for rock in rock_positions:
		if rock_texture != null:
			AssetTools.draw_centered(self, rock_texture, rock, Vector2(40, 40))
		else:
			draw_circle(rock, 12, Color(0.42, 0.45, 0.46))
			draw_circle(rock + Vector2(12, 6), 8, Color(0.32, 0.35, 0.36))
