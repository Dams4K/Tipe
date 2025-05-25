@tool
extends Node3D

@export_tool_button("Update") var update = update_mountain
@export var max_height := 1.0
@export var texture: Texture2D

@onready var plane_3d: MeshInstance3D = $Plane3D

func update_mountain():
	build_plane()

func build_plane():
	var plane := PlaneMesh.new()
	plane.size = texture.get_size()-Vector2.ONE
	plane.subdivide_width = texture.get_size().x-2
	plane.subdivide_depth = texture.get_size().y-2
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane.get_mesh_arrays())
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	#for i in range(mdt.get_vertex_count()):
		#var vertex: Vector3 = mdt.get_vertex(i)
		#var tex_position := Vector2(vertex.x, vertex.z) + texture.get_size() / 2
		#
		#vertex.y = max_height * texture.get_image().get_pixelv(tex_position).r
		#mdt.set_vertex(i, vertex)
	#
		## Calculate vertex normals, face-by-face.
	#for i in range(mdt.get_face_count()):
		## Get the index in the vertex array.
		#var a = mdt.get_face_vertex(i, 0)
		#var b = mdt.get_face_vertex(i, 1)
		#var c = mdt.get_face_vertex(i, 2)
		## Get vertex position using vertex index.
		#var ap = mdt.get_vertex(a)
		#var bp = mdt.get_vertex(b)
		#var cp = mdt.get_vertex(c)
		## Calculate face normal.
		#var n = (bp - cp).cross(ap - bp).normalized()
		## Add face normal to current vertex normal.
		## This will not result in perfect normals, but it will be close.
		#mdt.set_vertex_normal(a, n + mdt.get_vertex_normal(a))
		#mdt.set_vertex_normal(b, n + mdt.get_vertex_normal(b))
		#mdt.set_vertex_normal(c, n + mdt.get_vertex_normal(c))
#
	## Run through vertices one last time to normalize normals and
	## set color to normal.
	#for i in range(mdt.get_vertex_count()):
		#var v = mdt.get_vertex_normal(i).normalized()
		#mdt.set_vertex_normal(i, v)
		#mdt.set_vertex_color(i, Color(v.x, v.y, v.z))
	
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	
	plane_3d.mesh = mesh
