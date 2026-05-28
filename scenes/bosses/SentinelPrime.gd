class_name SentinelPrime
extends EnemyBase

signal boss_defeated

@export var phase2_hp_threshold: float = 0.5
@export var arena_half_width: float = 120.0
@export var charge_speed: float = 180.0
@export var wind_up_frames: int = 20      # always >= 8 per design rules
@export var attack_active_frames: int = 14

@onready var _attack_hitbox: Area2D = $AttackHitbox
@onready var _attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

var _phase: int = 1
var _is_invincible: bool = false
var _ai_state: String = "patrol"
var _facing: float = 1.0
var _patrol_origin: Vector2
var _state_timer: float = 0.0
var _wind_up_remaining: int = 0
var _attack_remaining: int = 0

func _ready() -> void:
	super._ready()
	_patrol_origin = global_position
	_attack_shape.disabled = true
	_attack_hitbox.area_entered.connect(_on_attack_area_entered)

func _process_ai(delta: float) -> void:
	_state_timer -= delta
	_check_phase()
	match _ai_state:
		"patrol":   _ai_patrol(delta)
		"wind_up":  _ai_wind_up()
		"attack":   _ai_attack()
		"recover":  _ai_recover()
		"shield":   pass  # hold still; broken only by Blood Cost
		"charge":   _ai_charge(delta)

func _check_phase() -> void:
	if _phase == 1:
		var max_hp := stats.max_health if stats else 20
		if _current_health <= int(float(max_hp) * phase2_hp_threshold):
			_phase = 2
			_enter_shield()

func _ai_patrol(delta: float) -> void:
	var speed := stats.move_speed if stats else 60.0
	velocity.x = _facing * speed
	_sprite.flip_h = _facing < 0.0
	var offset_x := global_position.x - _patrol_origin.x
	if absf(offset_x) >= arena_half_width:
		_facing = -sign(offset_x)

	var player := get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) < 55.0 and _state_timer <= 0.0:
		_enter_wind_up()

func _ai_wind_up() -> void:
	velocity.x = 0.0
	_wind_up_remaining -= 1
	if _wind_up_remaining <= 0:
		_ai_state = "attack"
		_attack_remaining = attack_active_frames
		_attack_shape.disabled = false
		AudioManager.play_sfx("boss_attack")

func _ai_attack() -> void:
	_attack_remaining -= 1
	if _attack_remaining <= 0:
		_attack_shape.disabled = true
		_ai_state = "recover"
		_state_timer = 0.9

func _ai_recover() -> void:
	velocity.x = 0.0
	if _state_timer <= 0.0:
		if _phase == 2:
			_enter_charge()
		else:
			_ai_state = "patrol"

func _enter_wind_up() -> void:
	_ai_state = "wind_up"
	_wind_up_remaining = wind_up_frames
	velocity.x = 0.0
	AudioManager.play_sfx("boss_wind_up")

func _enter_shield() -> void:
	_ai_state = "shield"
	_is_invincible = true
	velocity.x = 0.0
	_sprite.modulate = Color(0.6, 0.6, 2.0)
	AudioManager.play_sfx("boss_shield")

func _enter_charge() -> void:
	_ai_state = "charge"
	var player := get_tree().get_first_node_in_group("player")
	if player:
		_facing = sign(player.global_position.x - global_position.x)
	_state_timer = 1.0
	AudioManager.play_sfx("boss_charge")

func _ai_charge(_delta: float) -> void:
	velocity.x = _facing * charge_speed
	_sprite.flip_h = _facing < 0.0
	if _state_timer <= 0.0:
		_ai_state = "patrol"

# Overrides EnemyBase — shield is impenetrable except to Blood Cost.
func take_damage(amount: int, hit_direction: Vector2 = Vector2.ZERO, is_blood_cost: bool = false) -> void:
	if _is_invincible and not is_blood_cost:
		return
	if _is_invincible and is_blood_cost:
		_is_invincible = false
		_sprite.modulate = Color.WHITE
		_ai_state = "recover"
		_state_timer = 0.5
		AudioManager.play_sfx("boss_shield_break")
	_apply_damage(amount, hit_direction, is_blood_cost)

func _die() -> void:
	GameManager.unlock_ability("dash")
	boss_defeated.emit()
	AudioManager.play_sfx("boss_die")
	super._die()

func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player := area.get_parent()
		if player.has_method("take_damage"):
			player.take_damage(2, global_position)
