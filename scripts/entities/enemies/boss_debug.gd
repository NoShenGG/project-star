## Debug Player Implementation
class_name DebugBoss extends Boss

func _physics_process(delta):
	super(delta)
	
## These are called automatically, must impl to handle actual effects
func _attack() -> void:
	print("Boss Attacking!")

func _special_attack(_attack_id: int) -> void:
	print("Boss Special Attack!")

func _die() -> void:
	print("BOSS KILLED!")
	queue_free()

func _phase_change() -> void:
	print("Boss Changing Phase!")
