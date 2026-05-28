class_name EnemyStats
extends Resource

@export var max_health: int = 3
@export var move_speed: float = 60.0
@export var knockback_resistance: float = 0.0  # 0 = full knockback, 1 = immune
@export var scrap_drop_min: int = 1
@export var scrap_drop_max: int = 3
@export var contact_damage: int = 0            # Always 0 — enemies use hitboxes only
@export var hit_flash_duration: float = 0.1
@export var death_anim: String = "death"
