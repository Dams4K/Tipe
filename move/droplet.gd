extends Object
class_name Droplet

const MAX_ITERATIONS := 50

static var movements_image: Image
static var image: Image

var position: Vector2 = Vector2.ZERO

var direction: Vector2 = Vector2(0, 0)
var inertia: float = 0.3
var velocity: float = 1.0
var gravity: float = 9.8

var min_slope: float = 0.5

var sediment: float = 0.0
var capacity: float = 1.0
var erosion: float = 0.3
var deposition: float = 0.3

var water: float = 1.0
var evaporation: float = 0.05

var iteration := 0

func _init(position: Vector2):
	self.position = position

func move():
	movements_image.set_pixelv(position, Color(.0, .0, .0 ,.0))
	
	if out_of_bounds():
		return
	
	var P_x_y : float =  image.get_pixelv(position - Vector2.ONE).r
	var Px1_y: float =  image.get_pixelv(position + Vector2.RIGHT + Vector2.UP).r
	var P_xy1: float =  image.get_pixelv(position + Vector2.DOWN + Vector2.LEFT).r
	var Px1y1: float = image.get_pixelv(position + Vector2.ONE).r
	
	# u = uv.x
	# v = uv.y
	# values between [0, 1[
	var uv: Vector2 = position - Vector2(Vector2i(position))
	
	var g := Vector2(
		(Px1_y - P_x_y)/2 * (1 - uv.y) + (Px1y1 - P_xy1)/2 * uv.y,
		(P_xy1 - P_x_y)/2 * (1 - uv.x) + (Px1y1 - Px1_y)/2 * uv.x
	)
	
	direction = (direction * inertia - g.normalized() * (1 - inertia)).normalized()
	position += direction

	if not out_of_bounds():
		movements_image.set_pixelv(position, Color.GREEN)

func update():
	if iteration > MAX_ITERATIONS:
		return false
	
	if out_of_bounds():
		return false
	
	iteration += 1
	
	var old_position = position
	var old_height = image.get_pixelv(old_position).r
	move()
	var new_height = image.get_pixelv(position).r
	var delta_height = new_height - old_height
	
	if old_position == position:
		return false
	
	var carry_capacity = max(-delta_height, min_slope) * water * capacity * velocity
	
	if delta_height > 0.0:
		var amount_to_depose: float = min(delta_height, sediment) if delta_height > 0 else (sediment - carry_capacity) * deposition
		sediment -= amount_to_depose
		depose(amount_to_depose, old_position)
	else:
		var amount_to_erode: float = min(-delta_height, (carry_capacity-sediment) * erosion)
		erode(amount_to_erode, old_position)
	
	velocity = sqrt(max(0, velocity**2 - delta_height * gravity))
	if velocity == NAN:
		print("NAN")
	water *= (1 - evaporation)
	
	return true

func erode(amount: float, old_position: Vector2):
	var previous_amount = image.get_pixelv(old_position).r
	var eroded_amount = max(0.0, previous_amount - amount)
	
	image.set_pixelv(old_position, Color(eroded_amount, eroded_amount, eroded_amount))

func depose(amount: float, old_position: Vector2):
	var previous_amount = image.get_pixelv(old_position).r
	var deposed_amount = min(1.0, previous_amount + amount)
	
	image.set_pixelv(old_position, Color(deposed_amount, deposed_amount, deposed_amount))


func out_of_bounds() -> bool:
	return position.x < 1 or position.y < 1 or position.x >= image.get_width()-1 or position.y >= image.get_height()-1
