extends Object
class_name Droplet

static var movements_texture: Texture2D

var position: Vector2 = Vector2.ZERO
var texture: Texture2D = null

func _init(position: Vector2, texture: Texture2D):
	self.position = position
	self.texture = texture

func move() -> bool:
	var mvt_img = movements_texture.get_image()
	mvt_img.set_pixelv(position, Color(.0, .0, .0 ,.0))
	
	var is_alive = false
	
	if not out_of_bounds():
		is_alive = true
		var img = texture.get_image()
		
		var Pxy : float =  img.get_pixelv(position).r
		var Px1y: float =  img.get_pixelv(position + Vector2.RIGHT).r
		var Pxy1: float =  img.get_pixelv(position + Vector2.DOWN).r
		var Px1y1: float = img.get_pixelv(position + Vector2.ONE).r
		
		# u = uv.x
		# v = uv.y
		# values between [0, 1[
		var uv: Vector2 = Vector2(0.1, 0.1)
		var g := Vector2(
			(Px1y - Pxy) * (1 - uv.y) + (Px1y1 - Pxy1) * uv.y,
			(Pxy1 - Pxy) * (1 - uv.x) + (Px1y1 - Px1y) * uv.x
		)
		
		var dir_new := -g
		position += dir_new.normalized()
	
		mvt_img.set_pixelv(position, Color.GREEN)
	
	movements_texture = ImageTexture.create_from_image(mvt_img)
	return is_alive

func out_of_bounds() -> bool:
	return position.x < 0 or position.y < 0 or position.x >= texture.get_width()-1 or position.y >= texture.get_height()-1
