extends Node3D

const DOOR_MASK_INDEX := 2

@onready var animation_player := $AnimationPlayer
@onready var character_bot := $CharacterBot

var is_door_opened := false

func _input(event: InputEvent) -> void:
	if event.is_action_released("switch_trigger"):
		is_door_opened = !is_door_opened
		if is_door_opened:
			animation_player.play("open_door")
		else:
			animation_player.play_backwards("open_door")
			get_tree().call_group("character_bot", "change_access_to_region", DOOR_MASK_INDEX, is_door_opened)
		
		await animation_player.animation_finished
		
		if is_door_opened:
			get_tree().call_group("character_bot", "change_access_to_region", DOOR_MASK_INDEX, is_door_opened)
