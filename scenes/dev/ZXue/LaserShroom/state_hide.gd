extends EnemyState

@export_category("Properties")
@export var hide_range : float = 25.0
@export var hidetime : float = 5.0
@export var speed : float = 7.0
@export_category("Next States")
@export var post_hide_state : State

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	
	
	var distanceToPlayer:float = enemy.global_position.distance_to(enemy.player_ref.global_position)
	if(distanceToPlayer < hide_range):
		#calculate the imaginary safe position
		var safePos : Vector3  = -enemy.global_position.direction_to(enemy.player_ref.global_position) * distanceToPlayer * 2
		enemy.set_movement_target(safePos)


## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: HIDE")
	enemy._movement_speed = speed
	enemy.switchMesh(0)
	$HideTimer.start(hidetime)
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	trigger_finished.emit(post_hide_state.get_path())
	
## Called on state exit
func exit() -> void:
	pass

#when timer is out lasershroom should recover to approach state.
func _on_hide_timer_timeout() -> void:
	trigger_finished.emit(post_hide_state.get_path())
