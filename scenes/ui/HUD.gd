class_name HUD
extends CanvasLayer

@onready var _hearts: HBoxContainer = $TopBar/HeartsContainer
@onready var _petal_label: Label = $TopBar/PetalCounter
@onready var _zone_label: Label = $TopBar/ZoneLabel
@onready var _ability_icon: TextureRect = $TopBar/AbilityIcon

var _heart_nodes: Array[TextureRect] = []
var _heart_tex_full: ImageTexture
var _heart_tex_empty: ImageTexture

func _ready() -> void:
	_heart_tex_full = PlaceholderSpriteGenerator.generate_heart()
	_heart_tex_empty = _make_empty_heart()
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.petal_collected.connect(_on_petal_collected)
	LocalizationManager.language_changed.connect(_on_language_changed)
	_build_hearts(GameManager.max_health)
	_on_health_changed(GameManager.current_health, GameManager.max_health)
	_refresh_petal(GameManager.petals_collected.size())

func _build_hearts(max_hp: int) -> void:
	for node: TextureRect in _heart_nodes:
		node.queue_free()
	_heart_nodes.clear()
	for i in max_hp:
		var h := TextureRect.new()
		h.texture = _heart_tex_full
		h.custom_minimum_size = Vector2(8, 8)
		h.stretch_mode = TextureRect.STRETCH_KEEP
		_hearts.add_child(h)
		_heart_nodes.append(h)

func _on_health_changed(current: int, maximum: int) -> void:
	if _heart_nodes.size() != maximum:
		_build_hearts(maximum)
	for i in _heart_nodes.size():
		_heart_nodes[i].texture = _heart_tex_full if i < current else _heart_tex_empty

func _on_petal_collected(total: int) -> void:
	_refresh_petal(total)

func _refresh_petal(total: int) -> void:
	_petal_label.text = "%d/24" % total

func _on_language_changed(_locale: String) -> void:
	_refresh_petal(GameManager.petals_collected.size())

func set_zone(zone_name_key: String) -> void:
	_zone_label.text = tr(zone_name_key)

func set_ability_icon(texture: Texture2D) -> void:
	_ability_icon.texture = texture

func _make_empty_heart() -> ImageTexture:
	# Dimmed version of the heart for empty slots
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	var dark := Color(0.3, 0.05, 0.08)
	var px: Array[Vector2i] = [
		Vector2i(1,0), Vector2i(2,0), Vector2i(5,0), Vector2i(6,0),
		Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1),
		Vector2i(4,1), Vector2i(5,1), Vector2i(6,1), Vector2i(7,1),
		Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2),
		Vector2i(4,2), Vector2i(5,2), Vector2i(6,2), Vector2i(7,2),
		Vector2i(1,3), Vector2i(2,3), Vector2i(3,3), Vector2i(4,3),
		Vector2i(5,3), Vector2i(6,3),
		Vector2i(2,4), Vector2i(3,4), Vector2i(4,4), Vector2i(5,4),
		Vector2i(3,5), Vector2i(4,5), Vector2i(3,6), Vector2i(4,6),
		Vector2i(3,7),
	]
	for p: Vector2i in px:
		img.set_pixel(p.x, p.y, dark)
	return ImageTexture.create_from_image(img)
