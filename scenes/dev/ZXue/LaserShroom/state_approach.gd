extends State

var lasershroom : LaserShroom

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	# move closer to player
	lasershroom.set_movement_target(lasershroom.playerRef.global_position)
	
	#update
	var distanceToPlayer:float = lasershroom.global_position.distance_to(lasershroom.playerRef.global_position)
	if(distanceToPlayer < lasershroom.COUNTDOWN_RANGE):
		trigger_finished.emit("lockon")
	elif(lasershroom._hp <= 0):
		trigger_finished.emit("dead")

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: APPROACH")
	lasershroom = owner as LaserShroom
	lasershroom._movement_speed = lasershroom.SPEEDS["approach"]
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	trigger_finished.emit("lockon")
	
## Called on state exit
func exit() -> void:
	pass
