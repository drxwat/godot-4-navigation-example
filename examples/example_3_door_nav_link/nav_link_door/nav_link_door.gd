@tool
extends Node3D
class_name NavLinkDoor

@export var opened := false :
	set (value):
		opened = value
		update_state()
	get():
		return opened

@onready var animation_player := $AnimationPlayer
@onready var navigation_link := $NavigationLink3D

func _ready() -> void:
	update_state()
	
func open():
	opened = true
	await animation_player.animation_finished
	
func close():
	opened = false
	await animation_player.animation_finished

func update_state():
	if not animation_player or not navigation_link:
		return
	
	if opened:
		animation_player.play("open")
		navigation_link.enabled = true
	else:
		animation_player.play_backwards("open")
		navigation_link.enabled = false
