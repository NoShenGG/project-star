class_name StateMachineZF extends Node

#a dictionary of all the states of this SM
#loads in their names and directories. Load them as the subnode of this node.
var statePath:String = ""
@export var dict_allStates = {}
@export var stateScenes = []
@export var currentStateName:String
@export var defaultStateIndex = 0

func _init() -> void:
	for n in range(dict_allStates.size()):
		var thisPath = statePath + "/" + dict_allStates[n]
		if !FileAccess.file_exists(thisPath):
			print("error: FileAccess could not find state scene at " + thisPath + ".tscn")
			return
		else:
			var thisState:PackedScene = load(thisPath)
			stateScenes.append(thisState)
	
func _ready() -> void:
	callIn(dict_allStates[defaultStateIndex])
	
func callIn(nextStateName:String):
	var nextState:State = null
	if get_child(0) == null:
		print("error: StateMachine Node does not have a child node.")
		return
	else:
		var index:int = _findDicIndex(nextStateName)
		if index == -1:
			print("error: next state name not found in the dictionary keys.")
			return
		else:
			nextState = stateScenes[index].call("instantiate")
			if nextState == null:
				print("error: failed to instantiate state node")
				return
		#first load the next state. the entity should always read the state from the first child node so this should be all right.
		add_child(nextState)
		#update current state name
		currentStateName = dict_allStates[index].get_key()
		#free the current state
		get_child(0).queue_free()Z
	
		
func _findDicIndex(name:String) -> int:
	for n in range(dict_allStates.size()):
		if dict_allStates[n].get_key() == name:
			return n
	return -1
