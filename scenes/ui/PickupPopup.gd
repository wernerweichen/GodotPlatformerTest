class_name PickupPopup
extends Control

@export var display_duration: float = 2.0
@export var fade_duration: float = 0.4

@onready var _label: Label = $Label

func _ready() -> void:
	modulate.a = 0.0
	GameManager.item_picked_up.connect(_on_item_picked_up)

func _on_item_picked_up(item_data: ItemData) -> void:
	_label.text = tr(item_data.item_name_key)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	tween.tween_interval(display_duration)
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
