@tool
extends Node3D
class_name NavMeshRebakeDoor

signal baking_finished

@export var nav_region_group := "nav_region"
@export var opened := false :
	set (value):
		opened = value
		update_state()
	get():
		return opened

@onready var animation_player := $AnimationPlayer
@onready var nav_region = get_tree().get_first_node_in_group(nav_region_group) 

func _ready() -> void:
	update_state()
	
func open():
	opened = true
	await baking_finished
	
func close():
	opened = false
	await baking_finished

func update_state():
	if not animation_player:
		return
	
	if opened:
		animation_player.play("open")
	else:
		animation_player.play_backwards("open")
	
	# Дожидаемся завершения анимации для запекания
	await animation_player.animation_finished

	# Запекаем
	if nav_region is NavigationRegion3D:
		nav_region.bake_navigation_mesh()
		await nav_region.bake_finished
		await get_tree().physics_frame
		await get_tree().physics_frame
	baking_finished.emit()
