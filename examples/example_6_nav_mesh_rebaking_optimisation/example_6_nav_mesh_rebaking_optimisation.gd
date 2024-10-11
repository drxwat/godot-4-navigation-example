extends Node3D

const LEVEL_SOURCE_GEOMETRY_PATH := "res://resources/example_6_level_source_geometry.tres"

#@onready var door := $NavigationRegion3D/NavMeshRebakeDoor
@onready var navigation_region := $NavigationRegion3D

var level_source_geometry: NavigationMeshSourceGeometryData3D = load(LEVEL_SOURCE_GEOMETRY_PATH)
#var level_source_geometry: NavigationMeshSourceGeometryData3D

func _ready() -> void:
	call_deferred("update_navigation_region_fast", true)

func _input(event: InputEvent) -> void:
	if event.is_action_released("switch_trigger"):
		update_navigation_region_fast()


func update_navigation_region_fast(rewrite_cache := false):
	
	var time_start = Time.get_ticks_msec()
	
	# Создаем NavigationMesh
	var navigation_mesh = NavigationMesh.new()
	navigation_mesh.sample_partition_type = NavigationMesh.SAMPLE_PARTITION_MONOTONE
	navigation_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	navigation_mesh.agent_radius = 1.0
	
	# Парсим геометрию уровня, если нет закэшированных данных
	if rewrite_cache or not level_source_geometry:
		print("PARSING SOURCE GEOMETRY")
		level_source_geometry = NavigationMeshSourceGeometryData3D.new()
		NavigationServer3D.parse_source_geometry_data(navigation_mesh, level_source_geometry, self)
		ResourceSaver.save(level_source_geometry, LEVEL_SOURCE_GEOMETRY_PATH)
	
	
	# Клонируем данные, чтобы не модифицировать исходник
	var source_geometry: NavigationMeshSourceGeometryData3D = level_source_geometry.duplicate()
	
	# Добавляем препятствия
	var projected_obstructions := []
	for obstacle in get_tree().get_nodes_in_group("rebake_obstacle"):
		var projected_obstruction = obstacle.get_projected_obstruction()
		source_geometry.add_projected_obstruction(
			projected_obstruction["vertices"], 
			projected_obstruction["elevation"], 
			projected_obstruction["height"], false
			)
		
	# Запекаем NavigationMesh
	NavigationServer3D.bake_from_source_geometry_data(navigation_mesh, source_geometry, func(): 
		print("NavigationServer3D baking took: %s msec" % [str(Time.get_ticks_msec() - time_start)])
		)
	
	# Выставляем новый NavigationMesh
	navigation_region.navigation_mesh = navigation_mesh
	NavigationServer3D.region_set_navigation_mesh(navigation_region, navigation_mesh)
