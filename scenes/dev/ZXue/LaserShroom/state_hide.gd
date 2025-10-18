extends State

var lasershroom : LaserShroom

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	
	
	var distanceToPlayer:float = lasershroom.global_position.distance_to(lasershroom.playerRef.global_position)
	if(distanceToPlayer < lasershroom.HIDE_RANGE):
		#calculate the imaginary safe position
		var safePos : Vector3  = -lasershroom.global_position.direction_to(lasershroom.playerRef.global_position) * distanceToPlayer * 2
		lasershroom.set_movement_target(safePos)
	#update
	if(lasershroom._hp <= 0):
		trigger_finished.emit("dead")

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: HIDE")
	lasershroom = owner as LaserShroom
	lasershroom.resetBasis()
	lasershroom._movement_speed = lasershroom.SPEEDS["hide"]#make the velocity negative so it moves away instead of towards player
	lasershroom.switchMesh(0)
	#lasershroom.setHitboxStatus(false)
	$HideTimer.start(lasershroom.HIDETIME)
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	trigger_finished.emit("approach")
	
## Called on state exit
func exit() -> void:
	pass

#when timer is out lasershroom should recover to approach state.
func _on_hide_timer_timeout() -> void:
	trigger_finished.emit("approach")
