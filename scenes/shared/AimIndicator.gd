class_name AimIndicator
extends Node2D

enum Style { LINE, CONE, CIRCLE }

@export var style: Style = Style.LINE
@export var line_length: float = 48.0
@export var cone_half_angle_deg: float = 25.0
@export var cone_radius: float = 48.0
@export var circle_radius: float = 32.0
@export var indicator_color: Color = Color(1.0, 0.2, 0.2, 0.85)
@export var line_width: float = 1.5

func _ready() -> void:
	visible = false
	InputController.aim_mode_entered.connect(_on_aim_entered)
	InputController.aim_mode_exited.connect(_on_aim_exited)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _draw() -> void:
	if not visible:
		return
	match style:
		Style.LINE:
			_draw_line_indicator(InputController.aim_direction)
		Style.CONE:
			_draw_cone_indicator(InputController.aim_direction)
		Style.CIRCLE:
			_draw_circle_indicator()

func _draw_line_indicator(dir: Vector2) -> void:
	var tip: Vector2 = dir * line_length
	draw_line(Vector2.ZERO, tip, indicator_color, line_width)
	var perp: Vector2 = Vector2(-dir.y, dir.x) * 3.0
	draw_line(tip, tip - dir * 5.0 + perp, indicator_color, line_width)
	draw_line(tip, tip - dir * 5.0 - perp, indicator_color, line_width)

func _draw_cone_indicator(dir: Vector2) -> void:
	var half_rad: float = deg_to_rad(cone_half_angle_deg)
	draw_line(Vector2.ZERO, dir.rotated(-half_rad) * cone_radius, indicator_color, line_width)
	draw_line(Vector2.ZERO, dir.rotated(half_rad) * cone_radius, indicator_color, line_width)
	draw_arc(Vector2.ZERO, cone_radius, dir.angle() - half_rad, dir.angle() + half_rad,
			16, indicator_color, line_width)

func _draw_circle_indicator() -> void:
	draw_arc(Vector2.ZERO, circle_radius, 0.0, TAU, 32, indicator_color, line_width)

func _on_aim_entered(_skill_id: String) -> void:
	visible = true
	queue_redraw()

func _on_aim_exited() -> void:
	visible = false
	queue_redraw()
