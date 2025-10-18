extends State

var lasershroom : LaserShroom
var normalTransformBasis

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	# move closer to player
	# during lockon, speed is set to zero, so this line will only cause the lasershroom to face the player.
	# which is exactly what we need.
	# NO THIS DOES NOT WORK, NAVIGATION AGENT DOES NOT MAKE YOUR NODE TURN. I NEED IT TO TURN. original code:
	#lasershroom.set_movement_target(lasershroom.playerRef.global_position)
	lasershroom.look_at(lasershroom.playerRef.global_position)
	
	#update
	var distanceToPlayer:float = lasershroom.global_position.distance_to(lasershroom.playerRef.global_position)
	if(distanceToPlayer > lasershroom.DETECTION_RANGE):
		$LockTimer.stop()
		trigger_finished.emit("approach")
	elif(lasershroom._hp <= 0):
		trigger_finished.emit("dead")
	

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: LOCKON")
	lasershroom = owner as LaserShroom
	normalTransformBasis = lasershroom.transform.basis
	lasershroom._movement_speed = lasershroom.SPEEDS["lockon"]
	lasershroom.switchMesh(1)
	get_node("LockTimer").start(lasershroom.COUNTDOWN)
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	#by default goes back to state: approach
	trigger_finished.emit("approach")
	
## Called on state exit
func exit() -> void:
	pass

#when timer goes out, LaserShroom will fire.
func _on_lock_timer_timeout() -> void:
	trigger_finished.emit("fire")
