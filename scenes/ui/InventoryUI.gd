class_name InventoryUI
extends CanvasLayer

@onready var _item_list: VBoxContainer = $Background/Content/ScrollContainer/ItemList
@onready var _empty_label: Label = $Background/Content/EmptyLabel

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.item_used.connect(_on_item_used)

func _input(event: InputEvent) -> void:
	if not event.is_action_type():
		return
	if event.is_action_just_pressed("open_inventory"):
		if visible:
			_close()
		elif not get_tree().paused:
			_open()
		get_viewport().set_input_as_handled()
	elif event.is_action_just_pressed("pause") and visible:
		_close()
		get_viewport().set_input_as_handled()

func _open() -> void:
	_rebuild_list()
	show()
	get_tree().paused = true

func _close() -> void:
	hide()
	get_tree().paused = false

func _rebuild_list() -> void:
	for child: Node in _item_list.get_children():
		child.queue_free()

	var items: Array[Dictionary] = GameManager.inventory
	_empty_label.visible = items.is_empty()

	for i: int in items.size():
		var entry: Dictionary = items[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)

		var name_label := Label.new()
		name_label.text = tr(entry.get("name_key", ""))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 6)
		row.add_child(name_label)

		var type_label := Label.new()
		type_label.text = _type_tag(entry.get("type", 0))
		type_label.modulate = _type_colour(entry.get("type", 0))
		type_label.add_theme_font_size_override("font_size", 6)
		row.add_child(type_label)

		if entry.get("type") == ItemData.Type.CONSUMABLE:
			var use_btn := Button.new()
			use_btn.text = tr("INVENTORY_USE")
			use_btn.add_theme_font_size_override("font_size", 6)
			var slot := i
			use_btn.pressed.connect(func() -> void: _on_use_pressed(slot))
			row.add_child(use_btn)

		_item_list.add_child(row)

func _type_tag(type: int) -> String:
	match type:
		ItemData.Type.CONSUMABLE: return tr("ITEM_TYPE_CONSUMABLE")
		ItemData.Type.KEY_ITEM:   return tr("ITEM_TYPE_KEY_ITEM")
		ItemData.Type.UPGRADE:    return tr("ITEM_TYPE_UPGRADE")
		ItemData.Type.SCRAP:      return tr("ITEM_TYPE_SCRAP")
	return ""

func _type_colour(type: int) -> Color:
	match type:
		ItemData.Type.CONSUMABLE: return Color(0.8, 1.0, 0.8)
		ItemData.Type.KEY_ITEM:   return Color(1.0, 0.9, 0.6)
		ItemData.Type.UPGRADE:    return Color(0.7, 0.8, 1.0)
		ItemData.Type.SCRAP:      return Color(0.9, 0.9, 0.9)
	return Color.WHITE

func _on_use_pressed(slot_index: int) -> void:
	GameManager.use_item(slot_index)

func _on_item_used(_slot_index: int) -> void:
	_rebuild_list()
