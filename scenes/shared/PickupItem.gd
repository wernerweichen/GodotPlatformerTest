class_name PickupItem
extends Area2D

@export var item_data: ItemData
@export var hover_height: float = 4.0
@export var hover_period: float = 0.8

var _collected: bool = false

func _ready() -> void:
	add_to_group("collectibles")
	body_entered.connect(_on_body_entered)
	_start_hover()

func _start_hover() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - hover_height, hover_period)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y, hover_period)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	GameManager.add_item(item_data)
	AudioManager.play_sfx("item_pickup")
	queue_free()
