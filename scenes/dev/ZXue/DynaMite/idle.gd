extends State

var dynamite : Dynamite

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	#TODO: make DynaMite walk around when idle.
	#check if player is within detection range or not.
	var distanceToPlayer : float = dynamite.global_position.distance_to(dynamite.playerRef.global_position)
	print(distanceToPlayer)
	if (distanceToPlayer < dynamite.DETECTION_RANGE):
		trigger_finished.emit("approach")
	elif($"../.."._hp <= 0):
		trigger_finished.emit("dead")

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	dynamite = owner as Dynamite
	#dynamite.set_movement_target(dynamite.global_position)
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit finished.
func end() -> void:
	trigger_finished.emit("approach")

## Called on state exit
func exit() -> void:
	pass
