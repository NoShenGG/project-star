extends StateZF

signal idleEntry

func _init() -> void:
	dict_nextStates = {
		"APPROACH" : "state_approach",#if detected player and is too far
		"LOCK ON" : "state_lockon",#if detected player and is within lock range
		"DEAD" : "state_dead",#if HP -> 0
		"BROKEN" : "state_broken"#if BP -> 0
	}
	
func enter():
	get_parent().call("entry_idle")

#rules for updating to another state
func update():
	pass
