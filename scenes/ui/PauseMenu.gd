class_name PauseMenu
extends CanvasLayer

@onready var _root_panel: Control = $RootPanel
@onready var _main_buttons: VBoxContainer = $RootPanel/MainButtons
@onready var _lore_panel: Control = $RootPanel/LorePanel
@onready var _lore_scroll: RichTextLabel = $RootPanel/LorePanel/ScrollContainer/LoreText

func _ready() -> void:
	hide()
	# Must process while tree is paused so player can unpause
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if not event.is_action_type():
		return
	if event.is_action_pressed("pause") and not event.is_echo():
		if visible:
			_close()
			get_viewport().set_input_as_handled()
		elif not get_tree().paused:
			_open()
			get_viewport().set_input_as_handled()

func _open() -> void:
	show()
	get_tree().paused = true
	_main_buttons.show()
	_lore_panel.hide()

func _close() -> void:
	hide()
	get_tree().paused = false

func _on_resume_pressed() -> void:
	_close()

func _on_lore_archive_pressed() -> void:
	_main_buttons.hide()
	_lore_panel.show()
	_populate_lore()

func _populate_lore() -> void:
	if GameManager.petals_collected.is_empty():
		_lore_scroll.text = tr("LORE_ARCHIVE_EMPTY")
		return
	var text := ""
	for i: int in GameManager.petals_collected.size():
		text += "[b]%s %d[/b]\n" % [tr("LORE_ARCHIVE_FRAGMENT"), i + 1]
		text += "...\n\n"  # TODO: load from PetalMemory resources
	_lore_scroll.text = text

func _on_lore_back_pressed() -> void:
	_lore_panel.hide()
	_main_buttons.show()

func _on_options_pressed() -> void:
	pass  # TODO: options panel

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
