extends Sprite2D

const N = 10_000

@export var timer: Timer
@export var movements: Sprite2D
@export var base_texture: Texture2D

var droplets: Array[Droplet] = []
var total_droplets: int = 0

func _ready() -> void:
	randomize()
	await base_texture.changed
	
	var movements_image = Image.create(base_texture.get_width(), base_texture.get_height(), false, Image.FORMAT_RGBA8)
	var movements_image_texture: ImageTexture = ImageTexture.create_from_image(movements_image)
	
	#var image_data = ImageData.from_image(base_texture.get_image())
	
	var img = base_texture.get_image()
	var img32 := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBF)
	for i in range(img.get_width()):
		for j in range(img.get_height()):
			img32.set_pixel(i, j, img.get_pixel(i, j))
	
	Droplet.movements_image = movements_image_texture.get_image()
	Droplet.image = img32
	movements.texture = movements_image_texture
	
	Droplet.generate_weights(0)
	
	timer.timeout.connect(update)
	
	#for i in range(300_000):
		#var rx = randf_range(1.0, base_texture.get_width()-1.0)
		#var ry = randf_range(1.0, base_texture.get_height()-1.0)
		#var droplet = Droplet.new(Vector2(rx, ry))
		#droplets.append(droplet)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var droplet = Droplet.new(get_local_mouse_position())
		droplets.append(droplet)
		total_droplets += 1
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			for i in range(N):
				var rx = randf_range(0.0, base_texture.get_width()-1.0)
				var ry = randf_range(0.0, base_texture.get_height()-1.0)
				var droplet = Droplet.new(Vector2(rx, ry))
				droplets.append(droplet)
			total_droplets += N
		elif event.keycode == KEY_S:
			texture.get_image().save_jpg("res://results/after_%s_droplets.jpg" % total_droplets, 1.0)

func update():
	var q = len(droplets)
	if q != 0:
		#print("Amount of droplets: %s" % q)
		pass
	
	var droplets_alive: Array[Droplet] = []
	for droplet: Droplet in droplets:
		var is_alive = droplet.update()
		if is_alive:
			droplets_alive.append(droplet)
	
	droplets = droplets_alive
	
	movements.texture = ImageTexture.create_from_image(Droplet.movements_image)
	texture = ImageTexture.create_from_image(Droplet.image)
