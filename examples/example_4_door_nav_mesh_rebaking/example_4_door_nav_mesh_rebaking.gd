extends Node3D

@onready var door := $NavigationRegion3D/NavMeshRebakeDoor

func _input(event: InputEvent) -> void:
	if event.is_action_released("switch_trigger"):
		await door.close() if door.opened else await door.open()
		print("RECALCULATE")
		get_tree().call_group("character_bot", "recalculate_path")
