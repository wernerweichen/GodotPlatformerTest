class_name ItemData
extends Resource

enum Type {
	CONSUMABLE,  # Items that can be used from inventory
	KEY_ITEM,    # Quest / story items — cannot be used
	UPGRADE,     # Permanent stat upgrades
	SCRAP,       # Currency pickup items
}

@export var item_type: Type = Type.CONSUMABLE
@export var item_name_key: String = ""   # tr() key e.g. "ITEM_HEALTH_POTION"
@export var item_value: int = 0
@export var effect_id: String = ""       # "heal" for consumables; blank otherwise
