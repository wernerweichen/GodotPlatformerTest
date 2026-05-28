class_name PetalMemory
extends Resource

@export var id: String = ""
@export var zone: int = 1
@export var fragment_number: int = 0           # 1-24
@export_multiline var memory_en: String = ""   # Elena's words in English
@export_multiline var memory_zh: String = ""   # Elena's words in Chinese

# Returns the memory text for the current locale.
func get_memory_text() -> String:
	match LocalizationManager.get_language():
		"zh": return memory_zh
		_: return memory_en
