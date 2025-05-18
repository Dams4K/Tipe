extends Sprite2D

@export var timer: Timer
@export var movements: Sprite2D

var droplets: Array[Droplet] = []

func _ready() -> void:
	randomize()
	
	var movements_image = Image.create(texture.get_width(), texture.get_height(), false, Image.FORMAT_RGBA8)
	var movements_image_texture: ImageTexture = ImageTexture.create_from_image(movements_image)
	
	Droplet.movements_image = movements_image_texture.get_image()
	Droplet.image = texture.get_image()
	movements.texture = movements_image_texture
	
	timer.timeout.connect(update)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var droplet = Droplet.new(get_local_mouse_position())
		droplets.append(droplet)
	
	if event is InputEventKey and event.keycode == KEY_SPACE and event.pressed:
		for i in range(1_000):
			var rx = randf_range(1.0, texture.get_width()-2.0)
			var ry = randf_range(1.0, texture.get_height()-2.0)
			var droplet = Droplet.new(Vector2(rx, ry))
			droplets.append(droplet)
		print("Show time")

func update():
	var droplets_alive: Array[Droplet] = []
	for droplet: Droplet in droplets:
		var is_alive = droplet.update()
		if is_alive:
			droplets_alive.append(droplet)
	
	movements.texture = ImageTexture.create_from_image(Droplet.movements_image)
	texture = ImageTexture.create_from_image(Droplet.image)
