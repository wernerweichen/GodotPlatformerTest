class_name SilentAltar
extends Node2D

@onready var _prompt: Label = $PromptLabel
@onready var _interact_area: Area2D = $InteractArea

var _player_in_range: bool = false

func _ready() -> void:
	_prompt.hide()
	_interact_area.body_entered.connect(_on_body_entered)
	_interact_area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _player_in_range and Input.is_action_just_pressed("interact"):
		_activate()

func _activate() -> void:
	GameManager.respawn_zone = GameManager.current_zone
	GameManager.respawn_room = GameManager.current_room
	GameManager.respawn_position = global_position
	GameManager.current_health = GameManager.max_health
	GameManager.health_changed.emit(GameManager.current_health, GameManager.max_health)
	GameManager.save_game()
	AudioManager.play_sfx("altar_activate")
	_prompt.text = tr("ALTAR_SAVED")
	await get_tree().create_timer(1.5).timeout
	if _player_in_range:
		_prompt.text = tr("ALTAR_PROMPT")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_prompt.text = tr("ALTAR_PROMPT")
		_prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_prompt.hide()
