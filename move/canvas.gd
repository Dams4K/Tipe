extends Sprite2D

@export var timer: Timer
@export var movements: Sprite2D

var droplets: Array[Droplet] = []

func _ready() -> void:
	var movements_image = Image.create(texture.get_width(), texture.get_height(), false, Image.FORMAT_RGBA8)
	var movements_image_texture: ImageTexture = ImageTexture.create_from_image(movements_image)
	
	Droplet.movements_texture = movements_image_texture
	movements.texture = movements_image_texture
	
	timer.timeout.connect(update)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var droplet = Droplet.new(get_local_mouse_position(), texture)
		droplets.append(droplet)

func update():
	var droplets_alive: Array[Droplet] = []
	for droplet: Droplet in droplets:
		var is_alive = droplet.move()
		if is_alive:
			droplets_alive.append(droplet)
	
	movements.texture = Droplet.movements_texture
