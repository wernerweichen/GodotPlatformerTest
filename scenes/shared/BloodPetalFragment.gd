class_name BloodPetalFragment
extends Area2D

@export var petal_id: String = "petal_01"
@export var memory: PetalMemory

var _collected: bool = false

func _ready() -> void:
	if petal_id in GameManager.petals_collected:
		queue_free()
		return
	add_to_group("collectibles")
	body_entered.connect(_on_body_entered)
	$Sprite2D.texture = PlaceholderSpriteGenerator.generate_petal_icon()
	# Gentle hover loop
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 4.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	GameManager.collect_petal(petal_id)
	AudioManager.play_sfx("petal_collect")
	queue_free()
