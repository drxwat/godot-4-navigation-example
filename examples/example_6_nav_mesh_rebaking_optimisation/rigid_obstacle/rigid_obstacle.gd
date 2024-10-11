extends RigidBody3D

@onready var mesh_instance := $rect/Rect

var vertices: Array[Vector3] = []
var ground_plane := Plane(Vector3.UP)

@onready var level := get_tree().get_first_node_in_group("level")

func _ready() -> void:
	var mesh_data_tool := MeshDataTool.new()
	mesh_data_tool.create_from_surface(mesh_instance.mesh, 0)
	for i in mesh_data_tool.get_vertex_count():
		vertices.append(mesh_data_tool.get_vertex(i))

func get_projected_obstruction() -> Dictionary:
	var global_vertices = vertices.map(func(vertex: Vector3): return global_transform * vertex)
	var y_coordinates = global_vertices.map(func(vertex): return vertex.y)
	
	var projected_verteces = global_vertices.map(func(vertex): return _project_vertex_to_plane(vertex, ground_plane))
	var convex_hull := Geometry2D.convex_hull(projected_verteces)
	var hull_vertices = Array(convex_hull).map(func(point): return Vector3(point.x, 0.0, point.y))
	
	return {
		"vertices" : hull_vertices,
		"elevation" : y_coordinates.min(),
		"height" : y_coordinates.max(),
		"carve" : false
	}

func _project_vertex_to_plane(vertex: Vector3, plane: Plane) -> Vector2:
	var projection := plane.project(vertex)
	return Vector2(projection.x, projection.z)

func _on_sleeping_state_changed() -> void:
	if not sleeping:
		return
		
	level.update_navigation_region_fast()
