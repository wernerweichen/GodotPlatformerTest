extends Node

# Skill slot IDs — ability scenes listen to skill_aimed and check skill_id.
const SKILL_IDS: Array[String] = ["skill_1", "skill_2", "skill_3"]

# Emitted whenever the canonical facing direction flips.
signal facing_changed(new_facing: float)
# Emitted when a skill key is pressed and aim mode becomes active.
signal aim_mode_entered(skill_id: String)
# Emitted when aim mode ends (confirmed or cancelled).
signal aim_mode_exited()
# Emitted on aim confirmation; carries the skill slot and normalised world direction.
signal skill_aimed(skill_id: String, world_direction: Vector2)

# Public state — read by Player and AimIndicator each frame.
var is_aiming: bool = false
var current_skill_id: String = ""
var facing: float = 1.0
var aim_direction: Vector2 = Vector2.RIGHT

var _player: CharacterBody2D = null

# Call from Player._ready() so aim direction can be computed relative to the player.
func register_player(player: CharacterBody2D) -> void:
	_player = player

# Called by Player whenever horizontal movement changes facing.
# Ignored during aim mode — mouse controls facing then.
func set_movement_facing(dir: float) -> void:
	if is_aiming or is_zero_approx(dir):
		return
	_apply_facing(dir)

func _process(_delta: float) -> void:
	_poll_skill_keys()
	if is_aiming:
		_update_aim_direction()

func _unhandled_input(event: InputEvent) -> void:
	if not is_aiming:
		return
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_confirm_aim()
			get_viewport().set_input_as_handled()
			return
		if mb.pressed and mb.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_aim()
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("pause"):
		_cancel_aim()
		get_viewport().set_input_as_handled()

# ── Private ───────────────────────────────────────────────────────────────────

func _poll_skill_keys() -> void:
	for skill_id: String in SKILL_IDS:
		if Input.is_action_just_pressed(skill_id):
			_enter_aim_mode(skill_id)
			return
		if is_aiming and current_skill_id == skill_id and Input.is_action_just_released(skill_id):
			_confirm_aim()
			return

func _update_aim_direction() -> void:
	if _player == null:
		return
	var mouse_world: Vector2 = _player.get_global_mouse_position()
	var raw: Vector2 = _player.global_position.direction_to(mouse_world)
	if not is_zero_approx(raw.length_squared()):
		aim_direction = raw
	_apply_facing(aim_direction.x)

func _apply_facing(new_facing: float) -> void:
	var snapped: float = signf(new_facing)
	if is_zero_approx(snapped) or is_equal_approx(snapped, facing):
		return
	facing = snapped
	facing_changed.emit(facing)

func _enter_aim_mode(skill_id: String) -> void:
	if is_aiming:
		aim_mode_exited.emit()
	is_aiming = true
	current_skill_id = skill_id
	aim_mode_entered.emit(skill_id)

func _confirm_aim() -> void:
	var fired_skill: String = current_skill_id
	var fired_dir: Vector2 = aim_direction
	_exit_aim_mode()
	skill_aimed.emit(fired_skill, fired_dir)

func _cancel_aim() -> void:
	_exit_aim_mode()

func _exit_aim_mode() -> void:
	is_aiming = false
	current_skill_id = ""
	aim_mode_exited.emit()
