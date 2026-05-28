# Tests for the pickup item system.
# Requires GUT addon: https://github.com/bitwes/Gut
extends GutTest

func before_each() -> void:
	GameManager.inventory.clear()

func test_add_item_appends_to_inventory() -> void:
	var item := ItemData.new()
	item.item_type = "key_item"
	item.item_name_key = "ITEM_TEST"
	item.item_value = 10
	GameManager.add_item(item)
	assert_eq(GameManager.inventory.size(), 1)

func test_add_item_stores_correct_type() -> void:
	var item := ItemData.new()
	item.item_type = "consumable"
	item.item_name_key = "ITEM_TEST"
	item.item_value = 5
	GameManager.add_item(item)
	assert_eq(GameManager.inventory[0]["type"], "consumable")

func test_add_item_stores_correct_value() -> void:
	var item := ItemData.new()
	item.item_type = "consumable"
	item.item_name_key = "ITEM_TEST"
	item.item_value = 42
	GameManager.add_item(item)
	assert_eq(GameManager.inventory[0]["value"], 42)

func test_add_item_emits_signal() -> void:
	var item := ItemData.new()
	item.item_type = "key_item"
	item.item_name_key = "ITEM_TEST"
	item.item_value = 0
	watch_signals(GameManager)
	GameManager.add_item(item)
	assert_signal_emitted(GameManager, "item_picked_up")

func test_multiple_items_stack_in_inventory() -> void:
	for i in 3:
		var item := ItemData.new()
		item.item_type = "scrap"
		item.item_name_key = "ITEM_SPORE_CLUSTER"
		item.item_value = 10
		GameManager.add_item(item)
	assert_eq(GameManager.inventory.size(), 3)

func test_inventory_serializes_as_dict() -> void:
	var item := ItemData.new()
	item.item_type = "consumable"
	item.item_name_key = "ITEM_TEST"
	item.item_value = 7
	GameManager.add_item(item)
	var entry: Dictionary = GameManager.inventory[0]
	assert_has(entry, "type")
	assert_has(entry, "name_key")
	assert_has(entry, "value")

func test_inventory_persists_through_save_load() -> void:
	var item := ItemData.new()
	item.item_type = "key_item"
	item.item_name_key = "ITEM_TEST"
	item.item_value = 1
	GameManager.add_item(item)
	GameManager.save_game()
	GameManager.inventory.clear()
	GameManager.load_game()
	assert_eq(GameManager.inventory.size(), 1)
	assert_eq(GameManager.inventory[0]["type"], "key_item")
