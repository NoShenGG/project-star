extends EnemyState

## when idling, should we rotate towards player
@export var rotate_to_player : bool = true
@export var rotate_speed : float = 5


@export_category("Wait")
@export var wait_time : float = 1
## when the wait is over we transition to this state
@export var post_wait_state : State



@export_category("Player Distance")
## the maximum distance the player can take before exit
@export var max_player_distance : float = 1
## when the player gets too far from the enemy, interrupts wait
@export var player_far_state : State
var timer : SceneTreeTimer
var _running : bool = false

func enter(_prev_state: String, _data := {}) -> void:
	wait()
	entered.emit()
	
	_running = true

func wait():
	timer = get_tree().create_timer(wait_time)
	await timer.timeout
	if (enemy.death or !_running): return
	trigger_finished.emit(post_wait_state.get_path())

func end() -> void:
	if (timer != null):
		timer.stop()
	finished.emit()
	_running = false

func exit() -> void:
	if (timer != null):
		timer.stop()
	_running = false

func update(_delta: float) -> void:
	if (enemy.global_position.distance_to(GameManager.curr_player.global_position) > max_player_distance):
		trigger_finished.emit(player_far_state.get_path())
	
	var dir : Vector3 = (enemy.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * rotate_speed)

func physics_update(_delta: float) -> void:
	pass
