class_name Player
extends CharacterBody2D

signal died

enum State { IDLE, RUN, JUMP, FALL, WALL_SLIDE, DASH, BLOOD_COST, HURT, DEAD }

# ── Physics ───────────────────────────────────────────────────────────────
@export var gravity: float = 900.0
@export var max_fall_speed: float = 500.0
@export var move_speed: float = 120.0
@export var acceleration: float = 800.0
@export var friction: float = 1200.0

# ── Jump ──────────────────────────────────────────────────────────────────
@export var jump_velocity: float = -360.0
@export var jump_cut_velocity: float = -120.0
@export var coyote_frames: int = 6
@export var jump_buffer_frames: int = 8

# ── Wall ──────────────────────────────────────────────────────────────────
@export var wall_slide_gravity: float = 80.0
@export var wall_jump_velocity: Vector2 = Vector2(200.0, -300.0)

# ── Combat ────────────────────────────────────────────────────────────────
@export var max_health: int = 5
@export var hurt_duration: float = 0.4
@export var invincible_duration: float = 1.2
@export var knockback_velocity: Vector2 = Vector2(250.0, -150.0)

# ── Combo ─────────────────────────────────────────────────────────────────
@export var combo_window_frames: int = 40
@export var slash_hitbox_active_frames: int = 9

# ── Blood Cost ────────────────────────────────────────────────────────────
@export var blood_cost_charge_frames: int = 30
@export var blood_cost_hp_fraction: float = 0.25
@export var blood_cost_projectile_count: int = 5
@export var blood_cost_projectile_scene: PackedScene

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _attack_hitbox: Area2D = $AttackHitbox
@onready var _attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var _hurtbox: Area2D = $Hurtbox
@onready var _wall_left: RayCast2D = $WallLeft
@onready var _wall_right: RayCast2D = $WallRight
@onready var _ability_container: Node2D = $AbilityContainer

var state: State = State.IDLE
var current_health: int
var _facing: float = 1.0

var _coyote_remaining: int = 0
var _jump_buffer_remaining: int = 0
var _was_on_floor: bool = false
var _is_jumping: bool = false

var _combo_count: int = 0
var _combo_window_remaining: int = 0
var _attack_hold_frames: int = 0
var _slash_active_frames: int = 0
var _blood_cost_charging: bool = false

var _hurt_timer: float = 0.0
var _invincible_timer: float = 0.0

func _ready() -> void:
	add_to_group("player")
	current_health = GameManager.max_health
	_attack_shape.disabled = true
	_attack_hitbox.area_entered.connect(_on_attack_area_entered)
	GameManager.health_changed.connect(_on_gm_health_changed)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_tick(delta)
	_update_coyote()
	_handle_jump(delta)
	_handle_attack()
	_handle_movement(delta)
	_apply_gravity(delta)
	move_and_slide()
	_update_state()
	_update_visuals()

func _tick(delta: float) -> void:
	_hurt_timer = maxf(_hurt_timer - delta, 0.0)
	_invincible_timer = maxf(_invincible_timer - delta, 0.0)
	if _combo_window_remaining > 0:
		_combo_window_remaining -= 1
	else:
		_combo_count = 0
	if _slash_active_frames > 0:
		_slash_active_frames -= 1
		if _slash_active_frames == 0:
			_attack_shape.disabled = true

func _update_coyote() -> void:
	if is_on_floor():
		_coyote_remaining = coyote_frames
		_was_on_floor = true
		_is_jumping = false
	elif _was_on_floor and not _is_jumping:
		_coyote_remaining -= 1
		if _coyote_remaining <= 0:
			_was_on_floor = false

func _handle_jump(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_remaining = jump_buffer_frames
	elif _jump_buffer_remaining > 0:
		_jump_buffer_remaining -= 1

	if _jump_buffer_remaining > 0 and (_coyote_remaining > 0 or is_on_floor()):
		_do_jump()

	# Variable height — cut velocity on early release
	if Input.is_action_just_released("jump") and _is_jumping and velocity.y < jump_cut_velocity:
		velocity.y = jump_cut_velocity

	# Wall jump
	if not is_on_floor() and Input.is_action_just_pressed("jump"):
		if _wall_left.is_colliding():
			_do_wall_jump(1.0)
		elif _wall_right.is_colliding():
			_do_wall_jump(-1.0)

func _do_jump() -> void:
	velocity.y = jump_velocity
	_is_jumping = true
	_coyote_remaining = 0
	_jump_buffer_remaining = 0
	_was_on_floor = false
	AudioManager.play_sfx("jump")

func _do_wall_jump(dir: float) -> void:
	velocity = Vector2(wall_jump_velocity.x * dir, wall_jump_velocity.y)
	_is_jumping = true
	_facing = dir
	AudioManager.play_sfx("jump")

func _handle_attack() -> void:
	if _hurt_timer > 0.0 or state == State.DEAD:
		return

	if Input.is_action_pressed("attack"):
		_attack_hold_frames += 1
		if _attack_hold_frames >= blood_cost_charge_frames and not _blood_cost_charging:
			_blood_cost_charging = true
			_sprite.modulate = Color(1.5, 0.3, 0.3)

	if Input.is_action_just_released("attack"):
		if _blood_cost_charging:
			_do_blood_cost()
		elif _attack_hold_frames > 0:
			_do_slash()
		_attack_hold_frames = 0
		_blood_cost_charging = false

func _do_slash() -> void:
	if _combo_window_remaining > 0:
		_combo_count = (_combo_count + 1) % 3
	else:
		_combo_count = 0
	_combo_window_remaining = combo_window_frames
	_slash_active_frames = slash_hitbox_active_frames
	_attack_shape.disabled = false
	# Offset hitbox left or right based on facing
	_attack_hitbox.position.x = _facing * 12.0
	AudioManager.play_sfx("slash")

func _do_blood_cost() -> void:
	_sprite.modulate = Color.WHITE
	var cost := maxi(1, int(float(current_health) * blood_cost_hp_fraction))
	current_health = maxi(1, current_health - cost)
	GameManager.current_health = current_health
	GameManager.health_changed.emit(current_health, GameManager.max_health)
	_spawn_blood_cost_projectiles()
	AudioManager.play_sfx("blood_cost")

func _spawn_blood_cost_projectiles() -> void:
	if blood_cost_projectile_scene == null:
		return
	var spread := PI / 3.0
	for i in blood_cost_projectile_count:
		var t := float(i) / float(maxi(blood_cost_projectile_count - 1, 1))
		var angle := -spread * 0.5 + t * spread
		var base_dir := Vector2(_facing, -0.15).normalized()
		var proj: Node = blood_cost_projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_position = global_position + Vector2(_facing * 8.0, -4.0)
		if proj.has_method("set_direction"):
			proj.set_direction(base_dir.rotated(angle))

func _handle_movement(delta: float) -> void:
	if _hurt_timer > 0.0:
		return
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		_facing = sign(dir)
		velocity.x = move_toward(velocity.x, dir * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	var wall_dir := Input.get_axis("move_left", "move_right")
	var wall_sliding := (_wall_left.is_colliding() and wall_dir < 0.0) or \
						(_wall_right.is_colliding() and wall_dir > 0.0)
	if wall_sliding and velocity.y > 0.0:
		velocity.y = move_toward(velocity.y, 60.0, wall_slide_gravity * delta)
	else:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

func _update_state() -> void:
	if _hurt_timer > 0.0:
		state = State.HURT
		return
	if _blood_cost_charging:
		state = State.BLOOD_COST
		return
	var wall_dir := Input.get_axis("move_left", "move_right")
	var wall_sliding := not is_on_floor() and \
		((_wall_left.is_colliding() and wall_dir < 0.0) or (_wall_right.is_colliding() and wall_dir > 0.0))
	if is_on_floor():
		state = State.RUN if absf(velocity.x) > 5.0 else State.IDLE
	elif wall_sliding:
		state = State.WALL_SLIDE
	elif velocity.y < 0.0:
		state = State.JUMP
	else:
		state = State.FALL

func _update_visuals() -> void:
	_sprite.flip_h = _facing < 0.0
	if _invincible_timer > 0.0 and not _blood_cost_charging:
		_sprite.modulate.a = 0.5 if fmod(_invincible_timer, 0.2) > 0.1 else 1.0
	elif not _blood_cost_charging:
		_sprite.modulate = Color.WHITE

# Called by enemy attack hitboxes and hazards.
func take_damage(amount: int, hit_source_position: Vector2 = Vector2.ZERO) -> void:
	if _invincible_timer > 0.0 or state == State.DEAD:
		return
	current_health = maxi(0, current_health - amount)
	GameManager.current_health = current_health
	GameManager.health_changed.emit(current_health, GameManager.max_health)
	_invincible_timer = invincible_duration
	_hurt_timer = hurt_duration
	if hit_source_position != Vector2.ZERO:
		var kdir := sign(global_position.x - hit_source_position.x)
		velocity = Vector2(kdir * knockback_velocity.x, knockback_velocity.y)
	AudioManager.play_sfx("hurt")
	if current_health == 0:
		_die()

func _die() -> void:
	state = State.DEAD
	_sprite.modulate = Color(0.8, 0.1, 0.1, 1.0)
	died.emit()
	await get_tree().create_timer(1.5).timeout
	GameManager.on_player_died()

func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy := area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(1, global_position.direction_to(enemy.global_position))

func _on_gm_health_changed(current: int, _max: int) -> void:
	current_health = current
