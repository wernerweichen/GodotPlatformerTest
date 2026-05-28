# Tests for LocalizationManager — language switching, key coverage.
# Requires GUT addon: https://github.com/bitwes/Gut
extends GutTest

const REQUIRED_KEYS: Array[String] = [
	"MENU_PLAY", "MENU_OPTIONS", "MENU_QUIT",
	"HUD_PETALS_LABEL",
	"PAUSE_RESUME", "PAUSE_MAP", "PAUSE_LORE_ARCHIVE", "PAUSE_OPTIONS", "PAUSE_QUIT",
	"ALTAR_PROMPT", "ALTAR_SAVED",
	"ABILITY_DASH", "ABILITY_GROUND_POUND", "ABILITY_DOUBLE_JUMP", "ABILITY_PHASE_BLINK",
	"ZONE_1_NAME", "ZONE_2_NAME", "ZONE_3_NAME", "ZONE_4_NAME", "ZONE_5_NAME",
]

func test_supported_languages_contains_en_and_zh() -> void:
	var langs := LocalizationManager.get_supported_languages()
	assert_true("en" in langs)
	assert_true("zh" in langs)

func test_set_language_switches_locale() -> void:
	LocalizationManager.set_language("zh")
	assert_eq(LocalizationManager.get_language(), "zh")
	LocalizationManager.set_language("en")
	assert_eq(LocalizationManager.get_language(), "en")

func test_unsupported_language_does_not_crash() -> void:
	LocalizationManager.set_language("fr")   # unsupported — should warn, not crash
	assert_eq(LocalizationManager.get_language(), "en")  # unchanged

func test_all_required_keys_have_english_translations() -> void:
	LocalizationManager.set_language("en")
	for key: String in REQUIRED_KEYS:
		var translated := tr(key)
		assert_ne(translated, key, "Missing English translation for: %s" % key)

func test_all_required_keys_have_chinese_translations() -> void:
	LocalizationManager.set_language("zh")
	for key: String in REQUIRED_KEYS:
		var translated := tr(key)
		assert_ne(translated, key, "Missing Chinese translation for: %s" % key)
