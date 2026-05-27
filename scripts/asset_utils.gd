extends RefCounted
class_name AssetUtils

static func load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if not ResourceLoader.exists(path):
		return null
	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource as Texture2D
	return null

static func draw_centered(canvas: CanvasItem, texture: Texture2D, center: Vector2, max_size: Vector2) -> void:
	if texture == null:
		return
	var texture_size: Vector2 = texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var scale_factor: float = minf(max_size.x / texture_size.x, max_size.y / texture_size.y)
	var target_size: Vector2 = texture_size * scale_factor
	var rect: Rect2 = Rect2(center - target_size * 0.5, target_size)
	canvas.draw_texture_rect(texture, rect, false)
