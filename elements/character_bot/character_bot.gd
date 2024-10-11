extends CharacterBody3D
class_name CharacterBot

const ROTATION_SPEED := 5.0

@export var movement_speed: float = 4.0
@export var partroll_points: Array[Marker3D] = []

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var animation_state_machine = $AnimationTree.get("parameters/playback")

var patroll_point_index := 0

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	set_movement_target(global_position)
	
	if is_patrolling():
		set_movement_target(partroll_points[patroll_point_index].global_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta: float):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		animation_state_machine.travel("idle")
		return
	if navigation_agent.is_navigation_finished():
		if is_patrolling() and is_patroll_point_reached():
			set_next_patroll_point()
		else:
			animation_state_machine.travel("idle")
		return
		

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
		
	animation_state_machine.travel("run")
	global_transform = global_transform.interpolate_with(global_transform.looking_at(next_path_position), delta * ROTATION_SPEED)

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()

func change_access_to_region(mask: int, is_allowed: bool):
	navigation_agent.set_navigation_layer_value(mask, is_allowed)
	recalculate_path()

func recalculate_path():
	set_movement_target(navigation_agent.target_position)

func is_patrolling() -> bool:
	return partroll_points.size() > 0

func is_patroll_point_reached() -> bool:
	return global_position.distance_to(partroll_points[patroll_point_index].global_position) <= navigation_agent.target_desired_distance
	
func set_next_patroll_point():
	patroll_point_index = (patroll_point_index + 1) % partroll_points.size()
	set_movement_target(partroll_points[patroll_point_index].global_position)

# Доп. API для динамичного создания NavigationMap

func get_nav_agent() -> NavigationAgent3D:
	return navigation_agent
