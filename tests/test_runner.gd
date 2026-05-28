# GUT test runner configuration.
# Run from CLI: godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/ -gexit
#
# Install GUT via the Godot Asset Library (search "GUT") or:
# https://github.com/bitwes/Gut
extends SceneTree

func _init() -> void:
	print("Blood Bloom test suite — run via GUT addon")
	quit()
