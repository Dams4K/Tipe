@tool
extends Texture2D
class_name ErosionTexture2D

@export var base_texture: Texture2D

var texture: Texture2D

#region Particle class
class Particle extends Object:
	var pos := Vector2.ZERO
	var dir := Vector2.ZERO
	
	## Value between 0 and 1.[br]
	## I mean the gradient will be ignored[br]
	## 0 mean the previous direction will be ignored
	var inertia := 0.4
	
	var _vel: float # _ because idk if i will use this
	var water: float = 0.0 # water stored
	var sediment: float = 0.0 # setiment stored
	
	func get_pixel_pos() -> Vector2i:
		return Vector2i(pos)
#endregion

#region Texture2D functions
func _get_height() -> int:
	if !texture:
		return 0
	return texture.get_height()

func _get_width() -> int:
	if !texture:
		return 0
	return texture.get_width()

func _has_alpha() -> bool:
	if !texture:
		return false
	return texture.has_alpha()
	
func _is_pixel_opaque(x: int, y: int) -> bool:
	if !texture:
		return false
	return texture.is_pixel_opaque(x, y)
	
func _get_size() -> Vector2:
	if !texture:
		return Vector2.ZERO
	return texture.get_size()

func _draw(to_canvas_item, pos, modulate, transpose):
	if !texture:
		return
		
	texture.draw(to_canvas_item, pos, modulate, transpose)

func _draw_rect(to_canvas_item, rect, tile, modulate, transpose):
	if !texture:
		return
		
	texture.draw_rect(to_canvas_item, rect, tile, modulate, transpose)

func _draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv):
	if !texture:
		return
		
	texture.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)
#endregion

#region Erosion functions
func get_gradient(pt: Particle, image: Image) -> Vector2:
	var pixel_pos := pt.get_pixel_pos()
	
	var bottom_edge := image.get_height() == pixel_pos.y+1
	var right_edge := image.get_width() == pixel_pos.x+1
	
	#- Color (height) of the image at the pixel (x, y)
	# If the particle is at one edge of the image, we just get the color at pixel_pos
	var Pxy : float =  image.get_pixelv(pixel_pos).r
	var Px1y: float =  image.get_pixelv(pixel_pos + Vector2i.RIGHT * int(not right_edge)).r
	var Pxy1: float =  image.get_pixelv(pixel_pos + Vector2i.DOWN  * int(not bottom_edge)).r
	var Px1y1: float = image.get_pixelv(pixel_pos + Vector2i.ONE   * int(not (right_edge or bottom_edge))).r
	
	# u = uv.x
	# v = uv.y
	# values between [0, 1[
	var uv: Vector2 = pt.pos - Vector2(pixel_pos)
	
	return Vector2(
		(Px1y - Pxy) * (1 - uv.y) + (Px1y1 - Pxy1) * uv.y,
		(Pxy1 - Pxy) * (1 - uv.x) + (Px1y1 - Px1y) * uv.x
	)
#endregion
