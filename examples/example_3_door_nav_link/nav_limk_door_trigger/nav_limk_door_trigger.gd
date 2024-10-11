extends Node3D

@export_node_path("NavLinkDoor") var door_path
@export var autoclose_timeout := 0.0

@onready var animation_player := $AnimationPlayer
@onready var door: NavLinkDoor = get_node(door_path)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if door.opened:
		return
	animation_player.play("push")
	await animation_player.animation_finished
	await door.open()
	if autoclose_timeout > 0.0:
		await get_tree().create_timer(autoclose_timeout).timeout
		animation_player.play_backwards("push")
		await door.close()
		
