extends Node

@export var nova : FmodEventEmitter3D
@export var rene : FmodEventEmitter3D
@export var dawn : FmodEventEmitter3D

var last_character : Player

func swapping(player : Player):
	
	var nova_prob : float = randf_range(0,1) if player.name == "Nova" else 0
	var rene_prob : float = randf_range(0,1) if player.name == "Rene" else 0
	var dawn_prob : float = randf_range(0,1) if player.name == "Dawn" else 0
	
	if (nova_prob + rene_prob + dawn_prob > rene_prob + dawn_prob):
		nova.play(true)
	if (nova_prob + rene_prob + dawn_prob > nova_prob + dawn_prob):
		rene.play(true)
	if (nova_prob + rene_prob + dawn_prob > nova_prob + rene_prob):
		dawn.play(true)
	last_character = player
