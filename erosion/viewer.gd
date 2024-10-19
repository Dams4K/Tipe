extends HBoxContainer

@onready var erosion_texture: TextureRect = $ErosionTexture

func _on_next_button_pressed() -> void:
	erosion_texture.texture.next()
