extends EnemyState

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	# move closer to player
	enemy.set_movement_target(enemy.player_ref.global_position)
	
	#update
	var distanceToPlayer:float = enemy.global_position.distance_to(enemy.player_ref.global_position)
	if(distanceToPlayer < enemy.countdown_range):
		trigger_finished.emit("lockon")
	elif(enemy._hp <= 0):
		trigger_finished.emit("dead")

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: APPROACH")
	enemy._movement_speed = enemy.speeds["approach"]
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	trigger_finished.emit("lockon")
	
## Called on state exit
func exit() -> void:
	pass
