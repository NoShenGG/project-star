extends Node

@export var nova_swapin : FmodEventEmitter3D
@export var rene_swapin : FmodEventEmitter3D
@export var dawn_swapin : FmodEventEmitter3D
@export var nova_swapout : FmodEventEmitter3D
@export var rene_swapout : FmodEventEmitter3D
@export var dawn_swapout : FmodEventEmitter3D

var last_character : Player

func _ready() -> void:
	(owner as PlayerManager).new_player.connect(swapping)

func swapping(player : Player):
	if (randi_range(0,1) == 1 and last_character != null):
		play_swap_out(player)
	else:
		play_swap_in(player)
	last_character = player
	

func play_swap_in(player :Player):
	if player.name == "Nova":
		nova_swapin.play()
	if player.name == "Rene":
		rene_swapin.play()
	if player.name == "Dawn":
		dawn_swapin.play()
	
func play_swap_out(player :Player):
	if (last_character.name == "Nova"):
		nova_swapout.play()
	if (last_character.name == "Rene"):
		rene_swapout.play()
	if (last_character.name == "Dawn"):
		dawn_swapout.play()
