@tool
extends Node3D

@export_tool_button("Update") var update = update_mountain
@export var max_height := 1.0
@export var texture: Texture2D

@onready var plane_3d: MeshInstance3D = $Plane3D

func update_mountain():
	build_plane()

func build_plane():
	var img = texture.get_image()
	if img.is_compressed():
		img.decompress()
		texture = ImageTexture.create_from_image(img)
	
	var plane := PlaneMesh.new()
	plane.size = texture.get_size()-Vector2.ONE
	plane.subdivide_width = texture.get_size().x-2
	plane.subdivide_depth = texture.get_size().y-2
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane.get_mesh_arrays())
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex: Vector3 = mdt.get_vertex(i)
		var tex_position := Vector2(vertex.x, vertex.z) + texture.get_size() / 2
			
		vertex.y = max_height * texture.get_image().get_pixelv(tex_position).r
		mdt.set_vertex(i, vertex)
		
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	
	var st = SurfaceTool.new()
	st.create_from(mesh, 0)
	st.generate_normals()
	st.generate_tangents()
	
	plane_3d.mesh = st.commit()
