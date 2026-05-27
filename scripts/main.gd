extends Node2D

const EnemyScene: PackedScene = preload("res://scenes/Enemy.tscn")
const TowerScene: PackedScene = preload("res://scenes/Tower.tscn")
const TowerSpotScene: PackedScene = preload("res://scenes/TowerSpot.tscn")
const HitMarkerScene: PackedScene = preload("res://scenes/HitMarker.tscn")

@onready var map: GameMap = $Map
@onready var tower_spots_layer: Node2D = $TowerSpots
@onready var towers_layer: Node2D = $Towers
@onready var enemies_layer: Node2D = $Enemies
@onready var projectiles_layer: Node2D = $Projectiles
@onready var hit_markers_layer: Node2D = $HitMarkers

var path_points: Array[Vector2] = [
	Vector2(-40, 330),
	Vector2(180, 330),
	Vector2(180, 150),
	Vector2(430, 150),
	Vector2(430, 510),
	Vector2(720, 510),
	Vector2(720, 270),
	Vector2(1010, 270),
	Vector2(1010, 520),
	Vector2(1210, 520)
]

var spot_positions: Array[Vector2] = [
	Vector2(150, 430), Vector2(260, 220), Vector2(350, 95),
	Vector2(520, 240), Vector2(350, 455), Vector2(585, 585),
	Vector2(800, 430), Vector2(660, 205), Vector2(910, 205),
	Vector2(1090, 365), Vector2(930, 585)
]

var waves: Array[Dictionary] = [
	{"kind": "Goblin", "count": 6, "hp": 55, "speed": 82.0, "reward": 15, "damage": 1, "delay": 0.85},
	{"kind": "Bandit", "count": 8, "hp": 80, "speed": 70.0, "reward": 20, "damage": 1, "delay": 0.78},
	{"kind": "Ork", "count": 7, "hp": 135, "speed": 52.0, "reward": 28, "damage": 2, "delay": 0.95},
	{"kind": "Boss", "count": 1, "hp": 520, "speed": 38.0, "reward": 100, "damage": 6, "delay": 1.0}
]

var gold: int = 120
var castle_life: int = 12
var current_wave: int = 0
var enemies_left_to_spawn: int = 0
var active_wave_data: Dictionary = {}
var wave_running: bool = false

var spawn_timer: Timer
var gold_label: Label
var life_label: Label
var wave_label: Label
var info_label: Label
var start_button: Button

func _ready() -> void:
	add_to_group("game")
	projectiles_layer.add_to_group("projectiles_layer")
	if map.has_method("set_path_points"):
		map.set_path_points(path_points)
	_create_tower_spots()
	_create_ui()
	_create_spawn_timer()
	_update_ui("Platziere Türme und starte die erste Welle.")

func _create_spawn_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_spawn_next_enemy)
	add_child(spawn_timer)

func _create_tower_spots() -> void:
	for pos in spot_positions:
		var spot: TowerSpot = TowerSpotScene.instantiate() as TowerSpot
		spot.global_position = pos
		tower_spots_layer.add_child(spot)

func _create_ui() -> void:
	var ui: CanvasLayer = CanvasLayer.new()
	ui.name = "UI"
	add_child(ui)

	var panel: PanelContainer = PanelContainer.new()
	panel.position = Vector2(16, 16)
	panel.size = Vector2(630, 86)
	ui.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	margin.add_child(row)

	gold_label = Label.new()
	life_label = Label.new()
	wave_label = Label.new()
	info_label = Label.new()
	start_button = Button.new()

	start_button.text = "Welle starten"
	start_button.pressed.connect(start_next_wave)

	_add_ui_label(row, gold_label)
	_add_ui_label(row, life_label)
	_add_ui_label(row, wave_label)
	_add_ui_label(row, info_label)
	row.add_child(start_button)

	var help: Label = Label.new()
	help.text = "WASD/Pfeile: Spieler bewegen | Space/Rechtsklick: Nahkampfangriff | Linksklick auf Bauplatz: Turm bauen"
	help.position = Vector2(18, 108)
	help.add_theme_font_size_override("font_size", 16)
	help.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	ui.add_child(help)

func _add_ui_label(row: HBoxContainer, label: Label) -> void:
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)

func try_build_tower(spot: TowerSpot) -> void:
	if wave_running:
		_update_ui("Du kannst auch während der Welle bauen.")
	if spot.occupied:
		_update_ui("Hier steht schon ein Turm.")
		return
	if gold < spot.build_cost:
		_update_ui("Nicht genug Gold für einen Turm.")
		return

	gold -= int(spot.build_cost)
	spot.mark_occupied()
	var tower: Tower = TowerScene.instantiate() as Tower
	tower.global_position = spot.global_position
	towers_layer.add_child(tower)
	spawn_hit_marker("Turm gebaut", tower.global_position + Vector2(-28, -66), Color(0.75, 1.0, 0.45))
	_update_ui("Turm gebaut.")

func start_next_wave() -> void:
	if wave_running:
		return
	if current_wave >= waves.size():
		_update_ui("Alle Wellen sind geschafft. Sieg!")
		return

	active_wave_data = waves[current_wave]
	enemies_left_to_spawn = int(active_wave_data["count"])
	wave_running = true
	start_button.disabled = true
	spawn_timer.wait_time = float(active_wave_data["delay"])
	spawn_timer.start()
	_update_ui("Welle %d läuft: %s" % [current_wave + 1, String(active_wave_data["kind"])])

func _spawn_next_enemy() -> void:
	if enemies_left_to_spawn <= 0:
		spawn_timer.stop()
		return

	var enemy: Enemy = EnemyScene.instantiate() as Enemy
	enemies_layer.add_child(enemy)
	enemy.setup(
		path_points,
		int(active_wave_data["hp"]),
		float(active_wave_data["speed"]),
		int(active_wave_data["reward"]),
		int(active_wave_data["damage"]),
		String(active_wave_data["kind"])
	)
	enemy.died.connect(_on_enemy_died)
	enemy.reached_castle.connect(_on_enemy_reached_castle)
	enemies_left_to_spawn -= 1

func _process(_delta: float) -> void:
	if wave_running and enemies_left_to_spawn <= 0 and enemies_layer.get_child_count() == 0:
		wave_running = false
		current_wave += 1
		start_button.disabled = false
		if current_wave >= waves.size():
			start_button.disabled = true
			_update_ui("Sieg! Alle Wellen wurden besiegt.")
		else:
			_update_ui("Welle geschafft. Bereit für die nächste Welle.")

func _on_enemy_died(reward_amount: int, world_position: Vector2) -> void:
	gold += reward_amount
	spawn_hit_marker("+%dG" % reward_amount, world_position + Vector2(-10, -55), Color(1.0, 0.93, 0.35))
	_update_ui()

func _on_enemy_reached_castle(damage: int) -> void:
	castle_life -= damage
	spawn_hit_marker("Burg -%d" % damage, path_points[path_points.size() - 1] + Vector2(-40, -95), Color(1.0, 0.35, 0.25))
	if castle_life <= 0:
		castle_life = 0
		_game_over()
	else:
		_update_ui("Ein Gegner hat die Burg erreicht!")

func spawn_hit_marker(text: String, world_position: Vector2, color: Color) -> void:
	var marker: HitMarker = HitMarkerScene.instantiate() as HitMarker
	marker.position = world_position
	hit_markers_layer.add_child(marker)
	marker.setup(text, color)

func _game_over() -> void:
	wave_running = false
	spawn_timer.stop()
	start_button.disabled = true
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.queue_free()
	_update_ui("Game Over: Die Burg wurde zerstört.")

func _update_ui(message: String = "") -> void:
	if gold_label == null:
		return
	gold_label.text = "Gold: %d" % gold
	life_label.text = "Burg: %d" % castle_life
	wave_label.text = "Welle: %d/%d" % [mini(current_wave + 1, waves.size()), waves.size()]
	if message != "":
		info_label.text = message
