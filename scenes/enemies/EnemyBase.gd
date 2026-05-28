class_name EnemyBase
extends CharacterBody2D

signal enemy_died(scrap_amount: int)

@export var stats: EnemyStats
@export var gravity: float = 900.0
@export var max_fall_speed: float = 400.0

@onready var _sprite: Sprite2D = $Sprite2D

var _current_health: int
var _is_dead: bool = false
var _hit_flash_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	_current_health = stats.max_health if stats else 3
	# Register hurtbox group so player attacks can detect us
	var hurtbox := get_node_or_null("Hurtbox") as Node
	if hurtbox:
		hurtbox.add_to_group("enemy_hurtbox")

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	_tick_flash(delta)
	_process_ai(delta)
	move_and_slide()

# Override in subclasses to implement enemy behaviour.
func _process_ai(_delta: float) -> void:
	pass

func _tick_flash(delta: float) -> void:
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
		_sprite.modulate = Color(2.0, 0.5, 0.5) if _hit_flash_timer > 0.0 else Color.WHITE

# amount: damage dealt. hit_direction: normalised vector from attacker to this enemy.
# is_blood_cost: true when the hit comes from a Blood Cost projectile (bypasses shields).
func take_damage(amount: int, hit_direction: Vector2 = Vector2.ZERO, is_blood_cost: bool = false) -> void:
	if _is_dead:
		return
	_apply_damage(amount, hit_direction, is_blood_cost)

func _apply_damage(amount: int, hit_direction: Vector2, _is_blood_cost: bool) -> void:
	_current_health -= amount
	_hit_flash_timer = stats.hit_flash_duration if stats else 0.1
	if hit_direction != Vector2.ZERO:
		var resist := stats.knockback_resistance if stats else 0.0
		velocity += hit_direction * 200.0 * (1.0 - resist)
	AudioManager.play_sfx("enemy_hit")
	if _current_health <= 0:
		_die()

func _die() -> void:
	_is_dead = true
	var scrap: int = randi_range(
		stats.scrap_drop_min if stats else 1,
		stats.scrap_drop_max if stats else 3
	)
	GameManager.add_scrap(scrap)
	enemy_died.emit(scrap)
	AudioManager.play_sfx("enemy_die")
	set_collision_layer_value(3, false)
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate:a", 0.0, 0.35)
	tween.tween_callback(queue_free)
