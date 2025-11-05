extends State

var dynamite : Dynamite

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	# move closer to player
	dynamite.set_movement_target(dynamite.playerRef.global_position)
	
	#$"../..".velocity = $"../.."._movement_speed * ($"../..".playerRef.global_transform.origin - $"../..".global_transform.origin).normalized()
	#$"../..".move_and_slide()
	
	#update
	#check if player is within detection range or not.
	var distanceToPlayer:float = dynamite.global_position.distance_to(dynamite.playerRef.global_position)
	if(distanceToPlayer < dynamite.COUNTDOWN_RANGE):
		trigger_finished.emit("countdown")
	elif(dynamite._hp <= 0):
		trigger_finished.emit("dead")

func enter(_prev_state: String, _data := {}) -> void:
	dynamite = owner as Dynamite
	entered.emit()

func end() -> void:
	trigger_finished.emit("countdown")

func exit() -> void:
	pass
