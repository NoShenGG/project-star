## Test Enemy to be controlled by Mind Merger
class_name MergerTestEnemy extends Enemy

## distance from player before stopping
@export var attack_distance : float = 1

func _process(delta: float) -> void:
	if (death): return
	
	var player_distance = global_position.distance_to(GameManager.curr_player.global_position)
	if (player_distance > attack_distance and moving) or (player_distance > attack_distance + 3):
		var pos : Vector3 = GameManager.curr_player.global_position
		var dir : Vector3 = (global_position - GameManager.curr_player.global_position).normalized().slide(Vector3.UP) * attack_distance
		pos = GameManager.curr_player.global_position + dir
		
		set_movement_target(Vector3(pos.x, position.y, pos.z))
		rotate_y(global_basis.z.signed_angle_to(dir, Vector3.UP) * delta * 10)
	elif (is_attacking):
		rotate_y(global_basis.z.signed_angle_to(global_position - GameManager.curr_player.global_position, Vector3.UP) * delta * 10)
		
	super(delta)

signal on_attack

func attack() -> void:
	super()
	on_attack.emit()

func try_damage(damage_amount: float) -> bool:
	print("OUCH " + str(damage_amount))
	return super(damage_amount)
