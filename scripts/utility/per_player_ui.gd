extends Node

@export var nova_menu : Control
@export var rene_menu : Control
@export var dawn_menu : Control

func _ready() -> void:
	(owner as PlayerManager).new_player.connect(swap_menu)

func swap_menu(player : Player):
	print("changed")
	nova_menu.visible = player.name == "Nova"
	rene_menu.visible = player.name == "Rene"
	dawn_menu.visible = player.name == "Dawn"
