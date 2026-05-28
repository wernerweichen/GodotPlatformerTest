# Tests for the pickup item system.
# Requires GUT addon: https://github.com/bitwes/Gut
extends GutTest

func before_each() -> void:
	GameManager.inventory.clear()
	GameManager.max_health = 5
	GameManager.current_health = 5

func test_add_item_appends_to_inventory() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.KEY_ITEM
	item.item_name_key = "ITEM_TEST"
	item.item_value = 10
	GameManager.add_item(item)
	assert_eq(GameManager.inventory.size(), 1)

func test_add_item_stores_correct_type() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.CONSUMABLE
	item.item_name_key = "ITEM_TEST"
	item.item_value = 5
	GameManager.add_item(item)
	assert_eq(GameManager.inventory[0]["type"], ItemData.Type.CONSUMABLE)

func test_add_item_stores_correct_value() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.CONSUMABLE
	item.item_name_key = "ITEM_TEST"
	item.item_value = 42
	GameManager.add_item(item)
	assert_eq(GameManager.inventory[0]["value"], 42)

func test_add_item_stores_effect_id() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.CONSUMABLE
	item.item_name_key = "ITEM_HEALTH_POTION"
	item.item_value = 1
	item.effect_id = "heal"
	GameManager.add_item(item)
	assert_eq(GameManager.inventory[0]["effect_id"], "heal")

func test_add_item_emits_signal() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.KEY_ITEM
	item.item_name_key = "ITEM_TEST"
	item.item_value = 0
	watch_signals(GameManager)
	GameManager.add_item(item)
	assert_signal_emitted(GameManager, "item_picked_up")

func test_multiple_items_stack_in_inventory() -> void:
	for i in 3:
		var item := ItemData.new()
		item.item_type = ItemData.Type.SCRAP
		item.item_name_key = "ITEM_SPORE_CLUSTER"
		item.item_value = 10
		GameManager.add_item(item)
	assert_eq(GameManager.inventory.size(), 3)

func test_inventory_serializes_as_dict() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.CONSUMABLE
	item.item_name_key = "ITEM_TEST"
	item.item_value = 7
	item.effect_id = "heal"
	GameManager.add_item(item)
	var entry: Dictionary = GameManager.inventory[0]
	assert_has(entry, "type")
	assert_has(entry, "name_key")
	assert_has(entry, "value")
	assert_has(entry, "effect_id")

func test_inventory_persists_through_save_load() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.KEY_ITEM
	item.item_name_key = "ITEM_TEST"
	item.item_value = 1
	GameManager.add_item(item)
	GameManager.save_game()
	GameManager.inventory.clear()
	GameManager.load_game()
	assert_eq(GameManager.inventory.size(), 1)
	assert_eq(GameManager.inventory[0]["type"], ItemData.Type.KEY_ITEM)

func test_use_item_heals_player() -> void:
	GameManager.current_health = 3
	var item := ItemData.new()
	item.item_type = ItemData.Type.CONSUMABLE
	item.item_name_key = "ITEM_HEALTH_POTION"
	item.item_value = 2
	item.effect_id = "heal"
	GameManager.add_item(item)
	GameManager.use_item(0)
	assert_eq(GameManager.current_health, 5)

func test_use_item_does_not_exceed_max_health() -> void:
	GameManager.current_health = 5
	var item := ItemData.new()
	item.item_type = ItemData.Type.CONSUMABLE
	item.item_name_key = "ITEM_HEALTH_POTION"
	item.item_value = 3
	item.effect_id = "heal"
	GameManager.add_item(item)
	GameManager.use_item(0)
	assert_eq(GameManager.current_health, GameManager.max_health)

func test_use_item_removes_from_inventory() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.CONSUMABLE
	item.item_name_key = "ITEM_HEALTH_POTION"
	item.item_value = 1
	item.effect_id = "heal"
	GameManager.add_item(item)
	GameManager.use_item(0)
	assert_eq(GameManager.inventory.size(), 0)

func test_use_item_emits_signal() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.CONSUMABLE
	item.item_name_key = "ITEM_HEALTH_POTION"
	item.item_value = 1
	item.effect_id = "heal"
	GameManager.add_item(item)
	watch_signals(GameManager)
	GameManager.use_item(0)
	assert_signal_emitted(GameManager, "item_used")

func test_use_item_ignores_key_items() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.Type.KEY_ITEM
	item.item_name_key = "ITEM_TEST"
	item.item_value = 1
	GameManager.add_item(item)
	GameManager.use_item(0)
	assert_eq(GameManager.inventory.size(), 1)

func test_item_type_enum_values() -> void:
	assert_eq(ItemData.Type.CONSUMABLE, 0)
	assert_eq(ItemData.Type.KEY_ITEM, 1)
	assert_eq(ItemData.Type.UPGRADE, 2)
	assert_eq(ItemData.Type.SCRAP, 3)
