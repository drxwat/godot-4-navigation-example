extends CharacterBody3D

@export_node_path("Marker3D") var from_path
@export_node_path("Marker3D") var to_path
@export var speed := 2.0

@onready var from: Marker3D = get_node(from_path)
@onready var to: Marker3D= get_node(to_path)
@onready var navigation_obstacle := $NavigationObstacle3D

var moving_forward := true

func _physics_process(delta: float) -> void:
	var target: Vector3 = from.global_position if moving_forward else to.global_position
	var direction = global_position.direction_to(target)
	
	velocity = direction * speed
	navigation_obstacle.velocity = velocity
	
	move_and_slide()
	
	if global_position.distance_to(target) < 0.1:
		moving_forward = !moving_forward
