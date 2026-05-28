class_name GameCamera
extends Camera2D

@export var look_ahead_distance: float = 40.0
@export var look_ahead_lerp_speed: float = 4.0
@export var shake_decay: float = 6.0

var _target: CharacterBody2D
var _shake_intensity: float = 0.0
var _shake_timer: float = 0.0

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0

func _process(delta: float) -> void:
	_update_look_ahead(delta)
	_update_shake(delta)

# Assign the node the camera tracks. Call after spawning the player.
func set_target(target: CharacterBody2D) -> void:
	_target = target

# Trigger screen shake. intensity = max pixel offset, duration in seconds.
func shake(intensity: float, duration: float) -> void:
	_shake_intensity = maxf(intensity, _shake_intensity)
	_shake_timer = maxf(duration, _shake_timer)

func _update_look_ahead(delta: float) -> void:
	if _target == null:
		return
	var dir: float = signf(_target.velocity.x)
	var target_x := float(dir) * look_ahead_distance
	offset.x = lerpf(offset.x, target_x, look_ahead_lerp_speed * delta)

func _update_shake(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var s := _shake_intensity
		offset.y = randf_range(-s, s)
		_shake_intensity = lerpf(_shake_intensity, 0.0, shake_decay * delta)
	else:
		offset.y = 0.0
		_shake_intensity = 0.0
