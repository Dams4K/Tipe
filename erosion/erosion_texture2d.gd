@tool
extends Texture2D
class_name ErosionTexture2D


@export var base_texture: Texture2D :
	set(v):
		base_texture = v
		texture = base_texture

@export var radius := 2.0

var texture: Texture2D

var current_pt := Particle.new()
var current_image: Image

func next():
	if brush_weights.is_empty():
		brush_weights = generate_weights()
	move_particle(current_pt, current_image)

func next_particle():
	if current_image == null:
		current_image = base_texture.get_image()
	current_pt = Particle.new()
	current_pt.pos = Vector2(
		randf_range(0, current_image.get_size().x-1),
		randf_range(0, current_image.get_size().y-1),
	)

#region Particle class
class Particle extends Object:
	var pos := Vector2(
		randf(),
		randf()
	)
	## Should always be normalized
	var dir := Vector2.ZERO
	var velocity: float = 1.0
	var gravity: float = 9.8
	
	## Value between 0 and 1.[br]
	## I mean the gradient will be ignored[br]
	## 0 mean the previous direction will be ignored
	var inertia := 0.3
	
	## water stored
	var water: float = 1.0
	var evaporation: float = 0.05
	## setiment stored
	var sediment: float = 0.0
	## Used to prevent the capacity from falling to 0[br]
	## => allow erosion on flatter terrain
	var min_slope: float = 0.5
	
	var capacity: float = 1.0
	var erosion: float = 0.3
	var deposition: float = 0.3
	
	func move(image: Image) -> void:
		pos = (pos + dir.normalized()).clamp(Vector2.ZERO, image.get_size()-Vector2i.ONE)
	
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
	
	# u = uv.x
	# v = uv.y
	# values between [0, 1[
	var uv: Vector2 = pt.pos - Vector2(pixel_pos)
	var g = Vector2(
		(Px1y - Pxy) * (1 - uv.y) + (Px1y1 - Pxy1) * uv.y,
		(Pxy1 - Pxy) * (1 - uv.x) + (Px1y1 - Px1y) * uv.x
	)
	
	return g

func move_particle(pt: Particle, image: Image):
	# WARNING: DEBUG
	if image == null:
		current_image = base_texture.get_image()
		image = current_image
	
	var pos_old = pt.pos
	var h_old = get_image_height(pt.get_pixel_pos(), image)
	
	var g := get_gradient(pt, image)
	var dir_new := pt.dir * pt.inertia - g * (1 - pt.inertia)
	pt.dir = dir_new
	pt.move(image)
	
	#WARNING: DEBUG
	#current_image.set_pixelv(pt.pos, current_image.get_pixelv(pt.pos) + Color.GREEN * 0.2)
	#current_image.save_png("res://debug.png")
	
	var h_new = get_image_height(pt.get_pixel_pos(), image)
	
	var h_dif = h_new - h_old
	#print("Height diff: ", h_dif)
	## h_dif > 0: the new pos is higher, sediment must be dropped at the old pos
	## h_dif < 0: we erode
	
	var c = max(-h_dif, pt.min_slope) * pt.water * pt.capacity * pt.velocity
	
	if h_dif > 0 or pt.sediment > c:
		var amount_to_depose: float = min(h_dif, pt.sediment) if h_dif > 0 else (pt.sediment - c) * pt.deposition
		pt.sediment -= amount_to_depose
		
		depose(amount_to_depose, pos_old, image)
	else:
		# amount can't be higher than -h_dif else it will dig hole
		var amount_to_erode: float = min(-h_dif, (c-pt.sediment) * pt.erosion)
		erode(amount_to_erode, pos_old, image)
	
	pt.velocity = sqrt(pt.velocity**2 + h_dif*pt.gravity)
	pt.water *= (1 - pt.evaporation)
	
	texture = ImageTexture.create_from_image(image)
	emit_changed()

func get_image_height(pos: Vector2i, image: Image)  -> float:
	return image.get_pixelv(pos).r

func depose(amount: float, at: Vector2, image: Image) -> void:
	var pixel_pos := Vector2i(at)
	#var offset: Vector2 = at - Vector2(pixel_pos)
	#prints("amount deposed:", amount)
	var c := image.get_pixelv(pixel_pos)
	c.r += amount
	image.set_pixelv(pixel_pos, c)

func erode(amount: float, at: Vector2, image: Image) -> void:
	var at_i := Vector2i(at)
	for offset in brush_weights.keys():
		var pos := Vector2i(offset) + at_i
		if pos.x < 0 or pos.y < 0 or pos.x >= image.get_width() or pos.y >= image.get_height():
			continue
		
		var c := image.get_pixelv(pos)
		var weighed_amount = min(amount * brush_weights[offset], c.r)
		c.r -= weighed_amount
		current_pt.sediment += weighed_amount
		image.set_pixelv(pos, c)
	
	#prints("amount eroded:", amount)
	#var c := image.get_pixelv(pixel_pos)
	#c.r -= amount
	#image.set_pixelv(pixel_pos, c)

## keys: offsets
## values: weights
var brush_weights: Dictionary = {}

func generate_weights() -> Dictionary:
	var weights := {}
	var weight_sum = 0
	
	for j in range(-radius, radius+1):
		for i in range(-radius, radius+1):
			var pos := Vector2i(i, j)
			var sqr_dist := pos.length_squared()
			if sqr_dist > radius**2: # outside the circle
				continue
			
			var weight := 1 - sqrt(sqr_dist) / radius
			weight_sum += weight
			weights[pos] = weight
	
	var calculated_weights := {}
	for pos in weights:
		calculated_weights[pos] = weights[pos] / weight_sum * 10
	
	return calculated_weights

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

func get_image2():
	return current_image
