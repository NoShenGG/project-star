extends State
## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	pass

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("===STATE ENTRY [break]===")
	$"../..".setSpeed("broken")
	var breakRecoveryTimer:Timer
	breakRecoveryTimer.one_shot = true
	breakRecoveryTimer.timeout.connect(Callable(self, "exit"))
	breakRecoveryTimer.start($"../..".BREAK_RECOVERY)
	

## Call for another script to end this state. Should pick the next state and emit finished.
func end() -> void:
	finished.emit("approach")
	
## Called on state exit
func exit() -> void:
	'''
	TODO:
		reset break meter here
	'''
