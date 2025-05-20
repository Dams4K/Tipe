extends Object
class_name Droplet

const MAX_ITERATIONS := 30000

static var movements_image: Image
static var image: Image

var position: Vector2 = Vector2.ZERO

var direction: Vector2 = Vector2(0, 0)
var inertia: float = 0.1
var velocity: float = 1.0
var gravity: float = 0.098

var min_slope: float = 0.0

var sediment: float = 0.0
var capacity: float = 1.0
var erosion: float = 0.03
var deposition: float = 0.03

var water: float = 1.0
var evaporation: float = 0.001

var radius: int = 1

var iteration := 0

static var brush_weights: Dictionary = {}

static func generate_weights(radius: int):
	print("Start generating")
	var weights := {}
	var weight_sum = 0
	
	for j in range(-radius, radius+1):
		for i in range(-radius, radius+1):
			var pos := Vector2i(i, j)
			var sqr_dist := pos.length_squared()
			if sqr_dist > radius**2: # outside the circle
				continue
			
			var weight := 1 - sqrt(sqr_dist) / (radius+1)
			
			weight_sum += weight
			weights[pos] = weight
	
	var calculated_weights := {}
	for pos in weights:
		calculated_weights[pos] = weights[pos] / weight_sum
	
	Droplet.brush_weights = calculated_weights
	print(Droplet.brush_weights)
	print("Generated")

func _init(position: Vector2):
	self.position = position
	if brush_weights.is_empty():
		Droplet.generate_weights(radius)

func move():
	movements_image.set_pixelv(position, Color(.0, .0, .0 ,.0))
	
	if out_of_bounds():
		return
	
	var Pxy : float =  image.get_pixelv(position).r
	var Px1y: float =  image.get_pixelv(position + Vector2.RIGHT).r
	var Pxy1: float =  image.get_pixelv(position + Vector2.DOWN).r
	var Px1y1: float = image.get_pixelv(position + Vector2.ONE).r
	
	# u = uv.x
	# v = uv.y
	# values between [0, 1[
	var uv: Vector2 = position - Vector2(Vector2i(position))
	
	var g := Vector2(
		(Px1y - Pxy) * (1 - uv.y) + (Px1y1 - Pxy1) * uv.y,
		(Pxy1 - Pxy) * (1 - uv.x) + (Px1y1 - Px1y) * uv.x
	)
	
	direction = (direction * inertia - g.normalized() * (1 - inertia)).normalized()
	position += direction

	if not out_of_bounds():
		movements_image.set_pixelv(position, Color.GREEN)

func update():
	if iteration > MAX_ITERATIONS:
		die()
		return false
	
	iteration += 1
	
	var old_position = position
	var old_height = image.get_pixelv(old_position).r
	move()
	
	debug(old_position)
	
	if out_of_bounds():
		print("OOB")
		position = old_position
		die()
		return false
	
	
	var new_height = image.get_pixelv(position).r
	var delta_height = new_height - old_height
	
	if old_position == position:
		die()
		return false
	
	var carry_capacity = max(-delta_height, min_slope) * water * capacity * velocity
	if delta_height > 0.0 or sediment > carry_capacity:
		var amount_to_depose: float = min(delta_height, sediment) if delta_height > 0 else (sediment - carry_capacity) * deposition
		prints("D:", amount_to_depose)
		depose(amount_to_depose, old_position)
	else:
		var amount_to_erode: float = min(-delta_height, (carry_capacity-sediment) * erosion)
		erode(amount_to_erode, old_position)
	
	velocity = sqrt(max(0, velocity**2 - delta_height * gravity))
	if velocity == NAN:
		print("NAN")
	water *= (1 - evaporation)
	
	return true

func debug(old_position):
	var xy = Vector2i(0, 0)
	var x1y = Vector2i(1, 0)
	var xy1 = Vector2i(0, 1)
	var x1y1 = Vector2i(1, 1)
	#print()
	printt(image.get_pixelv(xy).r + image.get_pixelv(x1y).r + image.get_pixelv(xy1).r + image.get_pixelv(x1y1).r + sediment, image.get_pixelv(xy).r, image.get_pixelv(x1y).r, image.get_pixelv(xy1).r, image.get_pixelv(x1y1).r, sediment)
	#print("----")

func die():
	prints("Die:", sediment)
	movements_image.set_pixelv(position, Color(0.0, 0.0, 0.0, 0.0))
	depose(sediment, position)

func erode(amount: float, old_position: Vector2):
	var i_old_position := Vector2i(old_position)
	for offset in brush_weights.keys():
		var sub_position := Vector2i(offset) + i_old_position
		if sub_position.x < 0 or sub_position.y < 0 or sub_position.x >= image.get_width() or sub_position.y >= image.get_height():
			continue
		
		var previous_amount := image.get_pixelv(sub_position).r
		var weighed_amount = amount * brush_weights[offset]
		var delta_amount = previous_amount if previous_amount < weighed_amount else weighed_amount
		
		sediment += delta_amount
		
		var new_color = Color(previous_amount - delta_amount, previous_amount - delta_amount, previous_amount - delta_amount, 1.0)
		image.set_pixelv(sub_position, new_color)
	
	#var previous_amount = image.get_pixelv(old_position).r
	#var eroded_amount = max(0.0, previous_amount - amount)
	#
	#image.set_pixelv(old_position, Color(eroded_amount, eroded_amount, eroded_amount))

func depose(amount: float, old_position: Vector2):
	depose_pixel(old_position, amount)
	
	#var uv: Vector2 = old_position - Vector2(Vector2i(old_position))
	#
	#var xy = Vector2i(old_position)
	#var x1y = Vector2i(old_position) + Vector2i.RIGHT
	#var xy1 = Vector2i(old_position) + Vector2i.DOWN
	#var x1y1 = Vector2i(old_position) + Vector2i.RIGHT + Vector2i.DOWN
	#
	#print(xy)
	#
	#var xy_amount = amount * (1 - uv.x) * (1 - uv.y)
	#var x1y_amount = amount * uv.x * (1 - uv.y)
	#var xy1_amount = amount * (1 - uv.x) * uv.y
	#var x1y1_amount = amount * uv.x * uv.y
#
	#depose_pixel(xy, xy_amount)
	#depose_pixel(x1y, x1y_amount)
	#depose_pixel(xy1, xy1_amount)
	#depose_pixel(x1y1, x1y1_amount)

func depose_pixel(pixel_pos: Vector2i, amount: float):
	var previous_amount = image.get_pixelv(pixel_pos).r
	var deposed_amount = previous_amount + amount
	sediment -= amount
	image.set_pixelv(pixel_pos, Color(deposed_amount, deposed_amount, deposed_amount, 1.0))

func out_of_bounds() -> bool:
	return position.x < 0 or position.y < 0 or position.x >= image.get_width()-1 or position.y >= image.get_height()-1
