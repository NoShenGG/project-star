extends EnemyState
'''
once again, this part and the related stuff can't be done yet.
update on break meter and stuff and I'll get onto it.
'''

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	pass

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	pass
	
## Called on state exit
func exit() -> void:
	pass
