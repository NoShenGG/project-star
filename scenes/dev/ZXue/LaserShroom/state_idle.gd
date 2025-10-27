extends State

var lasershroom : LaserShroom

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	#check if player is within detection range or not.
	var distanceToPlayer : float = lasershroom.global_position.distance_to(lasershroom.player_ref.global_position)
	if (distanceToPlayer < lasershroom.detection_range):
		trigger_finished.emit("approach")
	elif(lasershroom._hp <= 0):
		trigger_finished.emit("dead")

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: IDLE")
	lasershroom = owner as LaserShroom
	lasershroom.set_movement_target(lasershroom.global_position)#not to move
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	trigger_finished.emit("approach")
	
## Called on state exit
func exit() -> void:
	pass
