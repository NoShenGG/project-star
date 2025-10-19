extends EnemyState

@export_category("Properties")
@export var speed : float = 0
@export var rotate_speed : float = 10.0
@export var countdown = 2.0
@export var detection_range = 20.0
@export_category("Next States")
@export var lost_track_state : State
@export var post_lock_state : State

## Called on state machine process
func update(_delta: float) -> void:
	pass

## Called on state machine physics process
func physics_update(_delta: float) -> void:
	#thank u Fire555 for the rotation code
	var dir : Vector3 = (enemy.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * rotate_speed)
	
	#update
	var distanceToPlayer:float = enemy.global_position.distance_to(enemy.player_ref.global_position)
	if(distanceToPlayer > detection_range):
		$LockTimer.stop()
		enemy.switchMesh(0)
		trigger_finished.emit(lost_track_state.get_path())

## Called on state enter. Make sure to emit entered.
func enter(_prev_state: String, _data := {}) -> void:
	print("[LaserShroom]Entering state: LOCKON")
	enemy._movement_speed = speed
	enemy.switchMesh(1)
	get_node("LockTimer").start(countdown)
	entered.emit()

## Call for another script to end this state. Should pick the next state and emit trigger_finished.
func end() -> void:
	#by default goes back to state: approach
	enemy.switchMesh(0)
	trigger_finished.emit(lost_track_state.get_path())
	
## Called on state exit
func exit() -> void:
	pass

#when timer goes out, LaserShroom will fire.
func _on_lock_timer_timeout() -> void:
	trigger_finished.emit(post_lock_state.get_path())
