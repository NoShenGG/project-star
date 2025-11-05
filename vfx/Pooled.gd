class_name Pooled3D
extends Node3D

var in_use : bool

signal pooled
signal spawned
signal pooling(this : Pooled3D)

func pool():
	
	pooling.emit(self)
	pooled.emit()

func spawn():
	in_use = true
	spawned.emit()
