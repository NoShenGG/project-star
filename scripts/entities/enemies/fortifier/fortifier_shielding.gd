class_name Shielding extends FortifierState

signal good

@export var rotate_speed : float = 10
@export var cast_time: float = 1.0
@export var retry_time: float = 3.0
@export var next_state: State

var shield = false


func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	fortifier.velocity = Vector3.ZERO
	await get_tree().create_timer(cast_time).timeout
	if not fortifier.shield():
		get_tree().create_timer(retry_time).timeout.connect(
			trigger_finished.emit.bind(get_path()))
	good.emit()
	trigger_finished.emit(next_state.get_path())

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	## goal: have the fortifier face the player while in this state
	var dir : Vector3 = (fortifier.global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP) 
	fortifier.rotate_y(fortifier.global_basis.z.signed_angle_to(dir, Vector3.UP) * delta * rotate_speed)
	# end of goal

func end() -> void:
	pass
		
func exit() -> void:
	finished.emit()
