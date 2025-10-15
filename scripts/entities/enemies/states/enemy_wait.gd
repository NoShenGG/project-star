extends EnemyState


@export_category("Wait")
@export var wait_time : float = 1
## when the wait is over we transition to this state
@export var post_wait_state : State



@export_category("Player Distance")
## the maximum distance the player can take before exit
@export var max_player_distance : float = 1
## when the player gets too far from the enemy, interrupts wait
@export var player_far_state : State

func enter(_prev_state: String, _data := {}) -> void:
	entered.emit()

func end() -> void:
	finished.emit()

func exit() -> void:
	pass

func update(_delta: float) -> void:
	if (enemy.global_position.distance_to(GameManager.curr_player.global_position) > max_player_distance):
		trigger_finished.emit(player_far_state.get_path())

func physics_update(_delta: float) -> void:
	pass
