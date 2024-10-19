@tool
extends Texture2D
class_name ErosionTexture2D


@export var base_texture: Texture2D :
	set(v):
		base_texture = v
		texture = base_texture

var texture: Texture2D

var current_pt := Particle.new()
var current_image: Image

func next():
	move_particle(current_pt, current_image)

#region Particle class
class Particle extends Object:
	var pos := Vector2(
		randf(),
		randf()
	)
	## Should always be normalized
	var dir := Vector2.ZERO
	
	## Value between 0 and 1.[br]
	## I mean the gradient will be ignored[br]
	## 0 mean the previous direction will be ignored
	var inertia := 0.0
	
	## water stored
	var water: float = 0.0
	## setiment stored
	var sediment: float = 0.0
	## Used to prevent the capacity from falling to 0[br]
	## => allow erosion on flatter terrain
	var p_min_slope: float = 0.5
	
	var p_capacity: float = 1.0
	
	func move(image: Image) -> void:
		pos = (pos + dir.normalized()).clamp(Vector2.ZERO, image.get_size())
	
	func get_pixel_pos() -> Vector2i:
		return Vector2i(pos)
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
	
	print("----")
	printt(image.get_pixelv(pixel_pos), image.get_pixelv(pixel_pos).to_html(false))
	printt(Pxy, Px1y)
	printt(Pxy1, Px1y1)
	#printt(pixel_pos, pixel_pos + Vector2i.RIGHT * int(not right_edge))
	#printt(pixel_pos + Vector2i.DOWN  * int(not bottom_edge), pixel_pos + Vector2i.ONE   * int(not (right_edge or bottom_edge)))
	
	# u = uv.x
	# v = uv.y
	# values between [0, 1[
	var uv: Vector2 = pt.pos - Vector2(pixel_pos)
	var g = Vector2(
		(Px1y - Pxy) * (1 - uv.y) + (Px1y1 - Pxy1) * uv.y,
		(Pxy1 - Pxy) * (1 - uv.x) + (Px1y1 - Px1y) * uv.x
	)
	printt("g: ", g, "uv: ", uv)
	return g

func move_particle(pt: Particle, image: Image):
	# WARNING: DEBUG
	if image == null:
		current_image = base_texture.get_image()
		image = current_image
	
	var h_old = get_image_height(pt.get_pixel_pos(), image)
	
	var g := get_gradient(pt, image)
	#var dir_new := pt.dir * pt.inertia - g * (1 - pt.inertia)
	var dir_new := - g * (1 - pt.inertia)
	pt.dir = dir_new
	pt.move(image)
	
	#WARNING: DEBUG
	current_image.set_pixelv(pt.pos, current_image.get_pixelv(pt.pos) + Color.GREEN * 0.2)
	current_image.save_png("res://debug.png")
	
	var h_new = get_image_height(pt.get_pixel_pos(), image)
	
	var h_dif = h_new - h_old
	print("Height diff: ", h_dif)
	## h_dif > 0: the new pos is higher, sediment has been dropped at the old pos
	## h_dif < 0: the carry capacity c must be calculated
	
	if h_dif < 0:
		var c = max(-h_dif, pt.p_min_slope) * pt.water * pt.p_capacity
	
	
	texture = ImageTexture.create_from_image(image)
	emit_changed()

func get_image_height(pos: Vector2i, image: Image)  -> float:
	return image.get_pixelv(pos).r
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

func _get_rid():
	texture.get_rid()
#endregion
