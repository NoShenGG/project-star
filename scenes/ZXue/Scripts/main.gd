extends Node3D

func _ready() -> void:
	$ReverseControlModule.reverseTime = 2.0
	$ReverseControlModule.reverseOnWithTimer()
