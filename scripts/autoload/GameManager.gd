extends Node

const SAVE_PATH: String = "user://save.json"
const TRUE_ENDING_PETAL_COUNT: int = 24

signal game_saved
signal game_loaded
signal petal_collected(total: int)
signal scrap_changed(total: int)
signal health_changed(current: int, maximum: int)

var current_zone: int = 1
var current_room: String = "start"
var respawn_zone: int = 1
var respawn_room: String = "start"
var respawn_position: Vector2 = Vector2.ZERO

var unlocked_abilities: Array[String] = []
var max_health: int = 5
var current_health: int = 5
var scrap_total: int = 0
var petals_collected: Array[String] = []

var _scrap_at_last_save: int = 0

func _ready() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		load_game()

# Writes current state to disk. Call only from SilentAltar.
func save_game() -> void:
	_scrap_at_last_save = scrap_total
	var data: Dictionary = {
		"current_zone": current_zone,
		"current_room": current_room,
		"respawn_zone": respawn_zone,
		"respawn_room": respawn_room,
		"respawn_position": {"x": respawn_position.x, "y": respawn_position.y},
		"unlocked_abilities": unlocked_abilities,
		"max_health": max_health,
		"scrap_total": scrap_total,
		"petals_collected": petals_collected,
		"language": LocalizationManager.get_language(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	game_saved.emit()

func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()
	var data: Dictionary = json.get_data()
	current_zone = data.get("current_zone", 1)
	current_room = data.get("current_room", "start")
	respawn_zone = data.get("respawn_zone", 1)
	respawn_room = data.get("respawn_room", "start")
	var pos: Dictionary = data.get("respawn_position", {"x": 0.0, "y": 0.0})
	respawn_position = Vector2(pos.x, pos.y)
	unlocked_abilities = Array(data.get("unlocked_abilities", []), TYPE_STRING, "", null)
	max_health = data.get("max_health", 5)
	current_health = max_health
	scrap_total = data.get("scrap_total", 0)
	_scrap_at_last_save = scrap_total
	petals_collected = Array(data.get("petals_collected", []), TYPE_STRING, "", null)
	var lang: String = data.get("language", "en")
	LocalizationManager.set_language(lang)
	game_loaded.emit()

# Called by enemies, hazards, and environmental kills.
func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		on_player_died()

# Respawn at last altar; scrap earned during the run is intentionally kept.
func on_player_died() -> void:
	var run_scrap := max(0, scrap_total - _scrap_at_last_save)
	load_game()
	scrap_total += run_scrap
	scrap_changed.emit(scrap_total)

func collect_petal(petal_id: String) -> void:
	if petal_id not in petals_collected:
		petals_collected.append(petal_id)
		petal_collected.emit(petals_collected.size())

func add_scrap(amount: int) -> void:
	scrap_total += amount
	scrap_changed.emit(scrap_total)

func spend_scrap(amount: int) -> bool:
	if scrap_total < amount:
		return false
	scrap_total -= amount
	scrap_changed.emit(scrap_total)
	return true

func unlock_ability(ability_id: String) -> void:
	if ability_id not in unlocked_abilities:
		unlocked_abilities.append(ability_id)

func has_ability(ability_id: String) -> bool:
	return ability_id in unlocked_abilities

func upgrade_max_health(amount: int = 1) -> void:
	max_health = min(max_health + amount, 8)
	current_health = max_health
	health_changed.emit(current_health, max_health)

func is_true_ending_unlocked() -> bool:
	return petals_collected.size() >= TRUE_ENDING_PETAL_COUNT
