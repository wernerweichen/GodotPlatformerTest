# Tests for InputController — aim mode state machine, facing priority, signal emissions.
# Requires GUT addon: https://github.com/bitwes/Gut
extends GutTest

func test_facing_defaults_right() -> void:
	pending("requires InputController autoload in scene tree")

func test_aim_mode_inactive_by_default() -> void:
	pending("requires InputController autoload in scene tree")

func test_enter_aim_mode_emits_aim_mode_entered() -> void:
	pending("requires InputController autoload and input simulation")

func test_confirm_aim_emits_skill_aimed_with_direction() -> void:
	pending("requires InputController autoload and input simulation")

func test_cancel_aim_emits_aim_mode_exited_without_skill_aimed() -> void:
	pending("requires InputController autoload and input simulation")

func test_movement_facing_ignored_during_aim_mode() -> void:
	pending("requires InputController autoload in scene tree")

func test_switching_skill_while_aiming_cancels_previous() -> void:
	pending("requires InputController autoload and input simulation")

func test_skill_ids_array_has_three_entries() -> void:
	pending("requires InputController autoload in scene tree")
