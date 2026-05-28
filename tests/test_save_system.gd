# Tests for GameManager save / load / death flow.
# Requires GUT addon: https://github.com/bitwes/Gut
extends GutTest

const TEST_SAVE := "user://blood_bloom_test_save.json"

func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)

func after_each() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(TEST_SAVE)

func test_save_creates_file() -> void:
	GameManager.save_game()
	assert_true(FileAccess.file_exists(GameManager.SAVE_PATH))

func test_load_restores_petal_count() -> void:
	GameManager.petals_collected.clear()
	GameManager.collect_petal("zone1_petal_01")
	GameManager.save_game()
	GameManager.petals_collected.clear()
	GameManager.load_game()
	assert_eq(GameManager.petals_collected.size(), 1)

func test_run_scrap_preserved_on_death() -> void:
	GameManager.scrap_total = 50
	GameManager.save_game()
	GameManager.scrap_total = 150   # 100 earned this run
	GameManager.on_player_died()
	assert_eq(GameManager.scrap_total, 150)  # saved(50) + run(100) = 150

func test_true_ending_requires_all_24_petals() -> void:
	GameManager.petals_collected.clear()
	assert_false(GameManager.is_true_ending_unlocked())
	for i in 24:
		GameManager.collect_petal("petal_%02d" % i)
	assert_true(GameManager.is_true_ending_unlocked())

func test_23_petals_does_not_unlock_true_ending() -> void:
	GameManager.petals_collected.clear()
	for i in 23:
		GameManager.collect_petal("petal_%02d" % i)
	assert_false(GameManager.is_true_ending_unlocked())

func test_spend_scrap_fails_when_insufficient() -> void:
	GameManager.scrap_total = 10
	var result := GameManager.spend_scrap(50)
	assert_false(result)
	assert_eq(GameManager.scrap_total, 10)
