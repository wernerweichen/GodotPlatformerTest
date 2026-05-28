class_name InfectedGuard
extends EnemyBase

# All tunable values exposed to Inspector
@export var patrol_distance: float = 80.0
@export var attack_range: float = 38.0
@export var attack_cooldown_duration: float = 2.0
@export var wind_up_frames: int = 16   # must be >= 8 per design rules
@export var attack_active_frames: int = 10

@onready var _attack_hitbox: Area2D = $AttackHitbox
@onready var _attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D

var _patrol_origin: Vector2
var _facing: float = 1.0
var _traveled: float = 0.0
var _attack_cooldown: float = 0.0
var _wind_up_remaining: int = 0
var _attack_remaining: int = 0
var _ai_state: String = "patrol"

func _ready() -> void:
	super._ready()
	_patrol_origin = global_position
	_attack_shape.disabled = true
	_attack_hitbox.area_entered.connect(_on_attack_area_entered)

func _process_ai(delta: float) -> void:
	_attack_cooldown -= delta
	match _ai_state:
		"patrol": _ai_patrol(delta)
		"wind_up": _ai_wind_up()
		"attack":  _ai_attack()
		"recover": _ai_recover(delta)

func _ai_patrol(delta: float) -> void:
	var speed := stats.move_speed if stats else 55.0
	velocity.x = _facing * speed
	_traveled += speed * delta
	_sprite.flip_h = _facing < 0.0

	if _traveled >= patrol_distance:
		_facing = -_facing
		_traveled = 0.0

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player and _attack_cooldown <= 0.0:
		if global_position.distance_to(player.global_position) <= attack_range:
			_ai_state = "wind_up"
			_wind_up_remaining = wind_up_frames
			velocity.x = 0.0
			AudioManager.play_sfx("enemy_attack_wind")

func _ai_wind_up() -> void:
	velocity.x = 0.0
	_wind_up_remaining -= 1
	if _wind_up_remaining <= 0:
		_ai_state = "attack"
		_attack_remaining = attack_active_frames
		_attack_shape.disabled = false

func _ai_attack() -> void:
	_attack_remaining -= 1
	if _attack_remaining <= 0:
		_attack_shape.disabled = true
		_ai_state = "recover"
		_attack_cooldown = attack_cooldown_duration

func _ai_recover(_delta: float) -> void:
	velocity.x = 0.0
	if _attack_cooldown <= 0.0:
		_ai_state = "patrol"

func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player := area.get_parent()
		if player.has_method("take_damage"):
			player.take_damage(1, global_position)
