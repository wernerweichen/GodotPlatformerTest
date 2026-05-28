extends Control

func _ready() -> void:
	AudioManager.play_music("main_menu")
	LocalizationManager.language_changed.connect(_on_language_changed)
	_refresh_labels()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/zones/zone_1_barracks/rooms/zone1_start.tscn")

func _on_options_pressed() -> void:
	# TODO: show options panel
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_language_changed(_locale: String) -> void:
	_refresh_labels()

func _refresh_labels() -> void:
	# Force-update any labels that need manual refresh (tr() auto-updates on locale change in Godot 4.4)
	pass
