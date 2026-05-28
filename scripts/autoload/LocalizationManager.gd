extends Node

const SUPPORTED_LANGUAGES: Array[String] = ["en", "zh"]
const DEFAULT_LANGUAGE: String = "en"

signal language_changed(locale: String)

var _current_locale: String = DEFAULT_LANGUAGE

func _ready() -> void:
	var system_lang := OS.get_locale_language()
	var locale := system_lang if system_lang in SUPPORTED_LANGUAGES else DEFAULT_LANGUAGE
	_apply_locale(locale)

# Switch the active language. Emits language_changed so UI nodes can refresh.
func set_language(locale: String) -> void:
	if locale not in SUPPORTED_LANGUAGES:
		push_warning("LocalizationManager: Unsupported locale: %s" % locale)
		return
	_apply_locale(locale)
	language_changed.emit(_current_locale)

func get_language() -> String:
	return _current_locale

func get_supported_languages() -> Array[String]:
	return SUPPORTED_LANGUAGES

func get_language_display_name(locale: String) -> String:
	match locale:
		"en": return "English"
		"zh": return "繁體中文"
		_: return locale

func _apply_locale(locale: String) -> void:
	_current_locale = locale
	TranslationServer.set_locale(locale)
