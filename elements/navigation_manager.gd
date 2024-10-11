extends Node3D

@export_node_path("Camera3D") var camera_path
@export_node_path("CharacterBot") var character_bot_path

@onready var camera: Camera3D = get_node(camera_path)
@onready var character_bot: CharacterBot = get_node(character_bot_path)

const RAY_LENGTH = 1000.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		var mouse_position := get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_position)
		var to = from + camera.project_ray_normal(mouse_position) * RAY_LENGTH
		
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var collision = get_world_3d().direct_space_state.intersect_ray(query)

		if collision.has("position"):
			set_character_movement_target(collision.get("position"))
			

func set_character_movement_target(target: Vector3) -> void:
	character_bot.set_movement_target(target)
