@tool
class_name TerrainGenerator
extends Node3D

@export_tool_button("generate") var g = create_terrain

@export_custom(PROPERTY_HINT_LINK, "suffix:m") var size: Vector2i = Vector2i(10, 10):
	set = set_size
#@export_custom(PROPERTY_HINT_NONE, "suffix:m") var resolution := 1.0

@export var height_map: Texture2D
@export var factor := 5.0

var mesh_instance: MeshInstance3D

func _enter_tree() -> void:
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)

func _exit_tree() -> void:
	remove_child(mesh_instance)

func _ready() -> void:
	create_terrain()


func get_plane_mesh() -> PlaneMesh:
	var plane = PlaneMesh.new()
	plane.size = Vector2(size)
	
	var subdivision := Vector2(size - Vector2i.ONE)
	plane.subdivide_depth = subdivision.x
	plane.subdivide_width = subdivision.y
	
	return plane



func generate_terrain() -> ArrayMesh:
	# Convert PlaneMesh to ArrayMesh
	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, get_plane_mesh().get_mesh_arrays())

	# Get MeshDataTool
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(arr_mesh, 0)

	# Add height
	if height_map != null:
	
		if height_map is ErosionTexture2D:
			for i in range(10_0):
				print(height_map.current_pt.pos)
				for j in range(30):
					height_map.next()
				height_map.next_particle()
		
		height_map.get_image().save_png("res://result.png")
		
		for i in range(mdt.get_vertex_count()):
			var pos = mdt.get_vertex(i)
			
			var v = height_map.get_image().get_pixel(int(pos.x + size.x/2), int(pos.z + size.y/2)).r
			pos.y = v * factor
			
			mdt.set_vertex(i, pos)
			
	
	# Apply modifications to the ArrayMesh
	arr_mesh.clear_surfaces()
	mdt.commit_to_surface(arr_mesh)
	
	return arr_mesh

func create_terrain():
	mesh_instance.mesh = null
	var terrain := generate_terrain()
	mesh_instance.mesh = terrain


# SETTERS
func set_size(value: Vector2i) -> void:
	size = value
	if is_inside_tree():
		create_terrain()
