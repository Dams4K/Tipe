@tool
extends Texture2D
class_name CombineTexture

enum Combination {
	ADD,
	MUL
}

@export_tool_button("Update") var update_action = func(): update_texture(); emit_changed()

@export var texture_a: Texture2D : set = set_texture_a
@export var texture_b: Texture2D : set = set_texture_b
@export var combine_method: Combination = Combination.MUL : set = set_combine_method

var texture: ImageTexture
var rid: RID

func _init() -> void:
	update_texture()

func update_texture():
	if texture_a == null or texture_b == null:
		print("no texture")
		return
	var image_a := texture_a.get_image()
	var image_b := texture_b.get_image()
	
	if image_a == null or image_b == null:
		print("no image")
		return
	
	assert(image_a.get_size() == image_b.get_size(), "Images a and b are not the same size")
	
	var image: Image
	
	match combine_method:
		Combination.MUL:
			image = mul(image_a, image_b)
	
	rid = RenderingServer.texture_2d_create(image)
	texture = ImageTexture.create_from_image(image)

func mul(a: Image, b: Image) -> Image:
	var mipmaps: bool = a.has_mipmaps() or b.has_mipmaps()
	var image := Image.create_empty(a.get_width(), a.get_height(), mipmaps, Image.FORMAT_RGBA8)
	
	for j in range(a.get_height()):
		for i in range(a.get_width()):
			image.set_pixel(i, j, a.get_pixel(i, j) * b.get_pixel(i, j))
	
	return image

func set_texture_a(value: Texture2D):
	texture_a = value
	update_texture()
	emit_changed()

func set_texture_b(value: Texture2D):
	texture_b = value
	update_texture()
	emit_changed()

func set_combine_method(value: Combination):
	combine_method = value
	update_texture()
	emit_changed()

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
	return rid
#endregion
