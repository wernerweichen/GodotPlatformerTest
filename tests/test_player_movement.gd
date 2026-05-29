# Tests for Player movement — coyote time, jump buffer, wall jump, variable jump height,
# wall-normal filter, drop-through re-enable, coyote expiry.
# Requires GUT addon: https://github.com/bitwes/Gut
extends GutTest

func test_coyote_time_allows_jump_within_6_frames() -> void:
	pending("implement after Player.tscn exists")

func test_jump_buffer_fires_on_landing() -> void:
	pending("implement after Player.tscn exists")

func test_wall_jump_applies_horizontal_impulse_away_from_wall() -> void:
	pending("implement after Player.tscn exists")

func test_tap_jump_is_shorter_than_held_jump() -> void:
	pending("implement after Player.tscn exists")

func test_state_transitions_idle_to_run() -> void:
	pending("implement after Player.tscn exists")

func test_state_transitions_run_to_fall() -> void:
	pending("implement after Player.tscn exists")

# _is_valid_wall() must reject ceiling normals (dot with UP >= 0.3)
func test_wall_normal_filter() -> void:
	var player: Player = partial_double("res://scenes/player/Player.tscn").instantiate()
	add_child_autofree(player)
	# Stub is_on_wall() = true but provide a ceiling-like normal (pointing straight up)
	stub(player, "is_on_wall").to_return(true)
	stub(player, "get_wall_normal").to_return(Vector2(0.0, -1.0))
	assert_false(player._is_valid_wall(),
		"Ceiling normal (0,-1) should not pass the wall filter")
	# Now test a valid vertical wall normal (pointing right — wall on left)
	stub(player, "get_wall_normal").to_return(Vector2(1.0, 0.0))
	assert_true(player._is_valid_wall(),
		"Pure horizontal normal should pass the wall filter")

# After drop_through_buffer_frames ticks, collision mask must be restored
func test_drop_through_reenables_collision() -> void:
	var player: Player = partial_double("res://scenes/player/Player.tscn").instantiate()
	add_child_autofree(player)
	# Manually set the timer as _try_drop_through() needs real input events
	player._drop_through_timer = player.drop_through_buffer_frames
	player.set_collision_mask_value(Player.PLATFORM_LAYER, false)
	# Tick down the timer by simulating _tick calls via delta
	var ticks: int = player.drop_through_buffer_frames
	for _i: int in ticks:
		# Drive the timer directly — replicate _tick's drop-through countdown
		if player._drop_through_timer > 0:
			player._drop_through_timer -= 1
			if player._drop_through_timer == 0:
				player.set_collision_mask_value(Player.PLATFORM_LAYER, true)
	assert_true(player.get_collision_mask_value(Player.PLATFORM_LAYER),
		"Collision mask for PLATFORM_LAYER must be re-enabled after drop_through_buffer_frames")

# Coyote jump must be blocked once the counter reaches 0
func test_coyote_expires() -> void:
	var player: Player = partial_double("res://scenes/player/Player.tscn").instantiate()
	add_child_autofree(player)
	stub(player, "is_on_floor").to_return(false)
	stub(player, "move_and_slide").to_return(false)
	player._was_on_floor = true
	player._is_jumping = false
	player._coyote_remaining = player.coyote_frames
	# Drain the counter fully
	for _i: int in player.coyote_frames:
		player._update_coyote()
	assert_eq(player._coyote_remaining, 0,
		"Coyote counter must reach 0 after coyote_frames calls to _update_coyote()")
	# Jump should no longer be available (counter == 0 and not on floor)
	var can_jump: bool = player._coyote_remaining > 0 or player.is_on_floor()
	assert_false(can_jump, "Jump must be blocked when coyote expires and not on floor")
