@tool
extends EnemyState

@export var normal_animation : AnimationState

## when idling, should we rotate towards player
@export var rotate_to_player : bool = true
@export var rotate_speed : float = 5
@export var rotate_animation : AnimationState
var _turning : bool = false

@export_category("Wait")
@export var wait_time : float = 1
## when the wait is over we transition to this state
@export var post_wait_state : State



@export_category("Player Distance")
## the maximum distance the player can take before exit
@export var max_player_distance : float = 1

## when the player gets too close from the enemy, interrupts wait
@export var player_close_state : State :
	set(value):
		if (value and player_far_state):
			player_far_state = null
			push_warning("Cannot have both a Player Far State and a Player Close State on an enemy_wait.gd")
		player_close_state = value
## when the player gets too far from the enemy, interrupts wait
@export var player_far_state : State :
	set(value):
		if (value and player_close_state):
			player_close_state = null
			push_warning("Cannot have both a Player Far State and a Player Close State on an enemy_wait.gd")
		player_far_state = value

var timer : SceneTreeTimer
var _running : bool = false

func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()
	wait()
	_running = true

func wait():
	timer = get_tree().create_timer(wait_time)
	await timer.timeout
	if (enemy.death or !_running): return
	if (post_wait_state): trigger_finished.emit(post_wait_state.get_path())

func end() -> void:
	timer = null
	finished.emit()
	_running = false
	_turning = false

func exit() -> void:
	timer = null
	_running = false
	_turning = false

func update(_delta: float) -> void:
	if (Engine.is_editor_hint()): return
	
	var player_far : bool = (enemy.global_position.distance_to(GameManager.curr_player.global_position) > max_player_distance)
	if (player_far_state and player_far):
		trigger_finished.emit(player_far_state.get_path())
		return
	if (player_close_state and (not player_far)):
		trigger_finished.emit(player_close_state.get_path())
		return
	
	var dir : Vector3 = (enemy.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP)
	var new_turning : bool = true
	if (absf(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP)) > 0.03):
		new_turning = true
	else:
		new_turning = false
	
	if (_turning != new_turning):
		if (new_turning and rotate_animation):
			rotate_animation.enter()
			print("turning")
		elif(!new_turning and normal_animation):
			normal_animation.enter()
			print("not  turning")
	_turning = new_turning
	enemy.rotate_y(enemy.global_basis.z.signed_angle_to(dir, Vector3.UP) * _delta * rotate_speed)

func physics_update(_delta: float) -> void:
	pass
