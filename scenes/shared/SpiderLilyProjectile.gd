class_name SpiderLilyProjectile
extends Area2D

@export var speed: float = 220.0
@export var damage: int = 3
@export var lifetime: float = 1.0

var _direction: Vector2 = Vector2.RIGHT
var _elapsed: float = 0.0

func _ready() -> void:
	$Sprite2D.texture = PlaceholderSpriteGenerator.generate_petal_icon()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

# Set the travel direction after instantiating.
func set_direction(dir: Vector2) -> void:
	_direction = dir.normalized()
	rotation = _direction.angle()

func _physics_process(delta: float) -> void:
	position += _direction * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage, _direction, true)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy := area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage, _direction, true)
		queue_free()
