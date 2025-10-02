extends StateMachineZF


func _init(path:String, states:Dictionary) -> void:
	statePath = path
	dict_allStates = states
	super()


#functions for the specific states to call on
func entry_idle():
	#add detection animation here?
	$"../IdleMoveAroundTimer".start($"..".idleMoveTime)
