extends Object
class_name ImageData

var data := PackedFloat64Array()

static func from_image(image: Image):
	var img_data = ImageData.new()
	#img_data.data = image.get_data()
	#print(image.get_data())
	#var_to_bytes()
	#print(image.get_data().to_float32_array())
