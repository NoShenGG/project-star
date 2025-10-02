class_name StateZF extends Node

signal finished(nextState:String)

#a dictionary of next states it can go to
@export var dict_nextStates = {}

func _init() -> void:
	pass
	
func _ready() -> void:
	pass
	
func enter():
	pass
	
func update():
	pass

func _physics_process(delta: float) -> void:
	update()

func manualExitTo(nextState:String):
	finished.emit(nextState)
