extends PlayerState


signal charge_count_increase(count: int)
signal max_charge_count

var time_active: float = 0
var charges: int = 0

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit(name, _previous_state_path)
	time_active = 0;
	charges = 0
	player.has_special = false
	

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.move(delta, 0.25)
	
	time_active += delta
	if charges < player.max_special_charges and floor(time_active / player.special_charge_time) > charges:
		charges += 1
		charge_count_increase.emit()
		print("emit")
		if charges == player.max_special_charges:
			max_charge_count.emit()
			print("emit max")

	if Input.is_action_just_pressed("synergy_burst"):
		finished.emit(BURSTING)
	if Input.is_action_just_pressed("dodge"):
		player.dash()
		finished.emit(MOVING if player.velocity else IDLE)
	elif  Input.is_action_just_released("special_attack"):
		if time_active > player.special_charge_time:
			finished.emit(ATTACKING_CHARGED_SPECIAL, {"charges": charges, "charge_time": time_active})
		else:
			finished.emit(ATTACKING_SPECIAL)
		
func end() -> void:
	pass
	
func exit() -> void:
	pass
