extends HBoxContainer

@onready var erosion_texture: TextureRect = $ErosionTexture

func _on_next_button_pressed() -> void:
	erosion_texture.texture.next()
	print(erosion_texture.texture.current_pt.pos)


func _on_start_button_pressed() -> void:
	for i in range(10_00):
		print(i)
		for j in range(30):
			erosion_texture.texture.next()
		erosion_texture.texture.next_particle()
	print("finished")


func _on_next_pt_button_pressed() -> void:
	erosion_texture.texture.next_particle()
	print(erosion_texture.texture.current_pt.pos)
