extends State

var dynamite : Dynamite = owner as Dynamite

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	pass

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	dynamite = owner as Dynamite
	print("===STATE ENTRY [dead]===")
	entered.emit()
	dynamite.trigger_death()

## Call for another script to end this state. Should pick the next state and emit finished.
func end() -> void:
	pass
	
## Called on state exit
func exit() -> void:
	pass
