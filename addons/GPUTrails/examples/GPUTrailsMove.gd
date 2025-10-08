@tool
extends Node3D

@export var speed : float = 1
@export var distance : float = 1
var time : float

func _process(delta: float) -> void:
	time += delta * speed
	position = Vector3(sin(time),0,0) * distance
