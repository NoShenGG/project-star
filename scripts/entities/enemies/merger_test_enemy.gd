## Test Enemy to be controlled by Mind Merger
class_name MergerTestEnemy extends Enemy

func _process(delta: float) -> void:
	var pos = $"/root/Prototype/PlayerManager/Nova".global_position
	set_movement_target(Vector3(pos.x, position.y, pos.z))
	super(delta)
	
func try_damage(damage_amount: float) -> bool:
	print("OUCH " + str(damage_amount))
	return super(damage_amount)
