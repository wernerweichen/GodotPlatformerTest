class_name PlaceholderSpriteGenerator
extends RefCounted

# Zone base colors — matches GDD §9 palette spec
const ZONE_COLORS: Dictionary = {
	1: Color(0.55, 0.58, 0.62),   # Steel grey — Iron Barracks
	2: Color(0.18, 0.42, 0.18),   # Dark green — Palace Gardens
	3: Color(0.08, 0.08, 0.10),   # Near-black — Catacombs
	4: Color(0.35, 0.08, 0.45),   # Deep purple — Magister's Tower
	5: Color(0.08, 0.0, 0.04),    # Black/crimson — Core
}

const CRIMSON: Color = Color(0.80, 0.08, 0.13)   # Spider lily red
const SILVER: Color = Color(0.88, 0.88, 0.92)
const BONE: Color = Color(0.92, 0.90, 0.85)

# Gale: 16×24, white armour, crimson chest wound
static func generate_player() -> ImageTexture:
	var img := Image.create(16, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	_rect(img, Rect2i(5, 0, 6, 4), BONE)                   # Head
	_rect(img, Rect2i(4, 4, 8, 14), SILVER)                # Body
	_rect(img, Rect2i(5, 8, 6, 4), CRIMSON)                # Chest wound
	_rect(img, Rect2i(2, 6, 3, 10), CRIMSON.darkened(0.3)) # Left vine cloak
	_rect(img, Rect2i(11, 6, 3, 10), CRIMSON.darkened(0.3))# Right vine cloak
	_rect(img, Rect2i(4, 18, 3, 6), SILVER.darkened(0.15)) # Left leg
	_rect(img, Rect2i(9, 18, 3, 6), SILVER.darkened(0.15)) # Right leg
	return ImageTexture.create_from_image(img)

# Tile: 16×16 solid with zone palette, darker border
static func generate_tile(zone: int) -> ImageTexture:
	var base: Color = ZONE_COLORS.get(zone, Color.GRAY)
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(base)
	var dark := base.darkened(0.35)
	for x in 16:
		img.set_pixel(x, 0, dark)
		img.set_pixel(x, 15, dark)
	for y in 16:
		img.set_pixel(0, y, dark)
		img.set_pixel(15, y, dark)
	return ImageTexture.create_from_image(img)

# Enemy: NxN rectangle with crimson eye dots
static func generate_enemy(size: int = 16) -> ImageTexture:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.28, 0.28, 0.32))
	var eye_size := max(2, size / 8)
	var eye_y := size / 4
	_rect(img, Rect2i(size / 4, eye_y, eye_size, eye_size), CRIMSON)
	_rect(img, Rect2i(size * 3 / 4 - eye_size, eye_y, eye_size, eye_size), CRIMSON)
	return ImageTexture.create_from_image(img)

# Boss: 64×64, more detailed silhouette
static func generate_boss() -> ImageTexture:
	return generate_enemy(64)

# HUD health heart: 8×8 spider lily bloom shape
static func generate_heart() -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	var px: Array[Vector2i] = [
		Vector2i(1,0), Vector2i(2,0), Vector2i(5,0), Vector2i(6,0),
		Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1),
		Vector2i(4,1), Vector2i(5,1), Vector2i(6,1), Vector2i(7,1),
		Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2),
		Vector2i(4,2), Vector2i(5,2), Vector2i(6,2), Vector2i(7,2),
		Vector2i(1,3), Vector2i(2,3), Vector2i(3,3), Vector2i(4,3),
		Vector2i(5,3), Vector2i(6,3),
		Vector2i(2,4), Vector2i(3,4), Vector2i(4,4), Vector2i(5,4),
		Vector2i(3,5), Vector2i(4,5),
		Vector2i(3,6), Vector2i(4,6),
		Vector2i(3,7),
	]
	for p: Vector2i in px:
		img.set_pixel(p.x, p.y, CRIMSON)
	return ImageTexture.create_from_image(img)

# Blood petal fragment icon: 8×8
static func generate_petal_icon() -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	_rect(img, Rect2i(3, 0, 2, 4), CRIMSON.darkened(0.2))
	_rect(img, Rect2i(0, 3, 4, 2), CRIMSON.darkened(0.2))
	_rect(img, Rect2i(4, 3, 4, 2), CRIMSON.darkened(0.2))
	_rect(img, Rect2i(3, 4, 2, 4), CRIMSON.darkened(0.2))
	img.set_pixel(3, 3, CRIMSON)
	img.set_pixel(4, 3, CRIMSON)
	img.set_pixel(3, 4, CRIMSON)
	img.set_pixel(4, 4, CRIMSON)
	return ImageTexture.create_from_image(img)

static func _rect(img: Image, r: Rect2i, color: Color) -> void:
	for x in r.size.x:
		for y in r.size.y:
			var px := r.position.x + x
			var py := r.position.y + y
			if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
				img.set_pixel(px, py, color)
