extends Node3D

@onready var standard_bot := $CharacterBot
@onready var huge_bot := $CharacterBotBig

func _ready() -> void:
	call_deferred("create_navigation_maps")


func create_navigation_maps():
	# Create a navigation mesh resource for each actor size.
	var navigation_mesh_standard_size: NavigationMesh = NavigationMesh.new()
	var navigation_mesh_huge_size: NavigationMesh = NavigationMesh.new()

	var standard_bot_agent: NavigationAgent3D = standard_bot.get_nav_agent()
	var huge_bot_agent: NavigationAgent3D = huge_bot.get_nav_agent()
	# Set appropriated agent parameters.
	navigation_mesh_standard_size.agent_radius = standard_bot_agent.radius
	navigation_mesh_standard_size.agent_height = standard_bot_agent.height
	navigation_mesh_huge_size.agent_radius = huge_bot_agent.radius
	navigation_mesh_huge_size.agent_height = huge_bot_agent.height

	# Create the source geometry resource that will hold the parsed geometry data.
	var source_geometry_data: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()

	# Parse the source geometry from the scene tree on the main thread.
	# The navigation mesh is only required for the parse settings so any of the three will do.
	NavigationServer3D.parse_source_geometry_data(navigation_mesh_standard_size, source_geometry_data, self)

	# Bake the navigation geometry for each agent size from the same source geometry.
	# If required for performance this baking step could also be done on background threads.
	NavigationServer3D.bake_from_source_geometry_data(navigation_mesh_standard_size, source_geometry_data)
	NavigationServer3D.bake_from_source_geometry_data(navigation_mesh_huge_size, source_geometry_data)

	# Create different navigation maps on the NavigationServer.
	var navigation_map_standard: RID = NavigationServer3D.map_create()
	var navigation_map_huge: RID = NavigationServer3D.map_create()

	# Set the new navigation maps as active.
	NavigationServer3D.map_set_active(navigation_map_standard, true)
	NavigationServer3D.map_set_active(navigation_map_huge, true)

	# Create a region for each map.
	var navigation_region_standard: RID = NavigationServer3D.region_create()
	var navigation_region_huge: RID = NavigationServer3D.region_create()

	# Add the regions to the maps.
	NavigationServer3D.region_set_map(navigation_region_standard, navigation_map_standard)
	NavigationServer3D.region_set_map(navigation_region_huge, navigation_map_huge)

	# Set navigation mesh for each region.
	NavigationServer3D.region_set_navigation_mesh(navigation_region_standard, navigation_mesh_standard_size)
	NavigationServer3D.region_set_navigation_mesh(navigation_region_huge, navigation_mesh_huge_size)
	
	standard_bot_agent.set_navigation_map(navigation_map_standard)
	huge_bot_agent.set_navigation_map(navigation_map_huge)
