extends Object
class_name ImageData

## Useless
var height: int
var width: int

var data := PackedFloat64Array()

static func from_image(image: Image):
	var img_data = ImageData.new()
	for j in range(image.get_height()):
		for i in range(image.get_width()):
			img_data.data.append(image.get_pixel(i, j).r)
	img_data.width = image.get_width()
	img_data.height = image.get_height()
	return img_data

func get_pixel(x: int, y: int) -> float:
	return data[y * width + x]
func get_pixelv(pos: Vector2i) -> float:
	return data[pos.y * width + pos.x]
