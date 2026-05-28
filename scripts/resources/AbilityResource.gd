class_name AbilityResource
extends Resource

@export var id: String = ""
@export var display_name_key: String = ""   # tr() key e.g. "ABILITY_DASH"
@export var description_key: String = ""    # tr() key for description
@export var icon: Texture2D
@export var flower: String = ""
@export var cooldown: float = 0.0
@export var scene: PackedScene                # Ability component scene
