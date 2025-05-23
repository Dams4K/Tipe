extends Node2D

@export var texture: Texture2D

@export var value := 1.0
@export var step := 0.00001

@onready var sprite_2d: Sprite2D = $Sprite2D

var img: Image
var pos := Vector2i.ZERO

func _ready() -> void:
	sprite_2d.texture = texture
	img = texture.get_image()
	img.set_data(img.get_width(), img.get_height(), false, Image.FORMAT_RF, img.get_data())

func _process(delta: float) -> void:
	if img.get_pixelv(pos).r != value:
		printt("Dif", img.get_pixelv(pos).r, value)
	
	value -= step
	img.set_pixelv(pos, Color(value, value, value, 1.0))
	
	sprite_2d.texture = ImageTexture.create_from_image(img)
