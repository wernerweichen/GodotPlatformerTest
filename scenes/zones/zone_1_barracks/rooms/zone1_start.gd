extends Node2D

@onready var _player: Player = $Player
@onready var _camera: GameCamera = $Player/Camera

func _ready() -> void:
	GameManager.current_zone = 1
	GameManager.current_room = "zone1_start"

	# Wire camera to player
	_camera.set_target(_player)
	_camera.limit_left = 0
	_camera.limit_right = 320
	_camera.limit_top = 0
	_camera.limit_bottom = 180

	# Generate player placeholder sprite
	_player.get_node("Sprite2D").texture = PlaceholderSpriteGenerator.generate_player()

	# Generate enemy placeholder sprites
	for guard in get_tree().get_nodes_in_group("enemies"):
		var sp: Sprite2D = guard.get_node_or_null("Sprite2D")
		if sp:
			sp.texture = PlaceholderSpriteGenerator.generate_enemy(16)

	# Update HUD zone label
	var hud := get_node_or_null("HUD")
	if hud and hud.has_method("set_zone"):
		hud.set_zone("ZONE_1_NAME")

	AudioManager.play_music("zone_1")
