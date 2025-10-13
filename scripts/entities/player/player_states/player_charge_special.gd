extends PlayerState


signal charge_count_increase(count: int)
signal max_charge_count

var time_active: float = 0
var charges: int = 0

func enter(_previous_state_path: String, data := {}) -> void:
	entered.emit()
	time_active = data.get("time", 0);
	charges = floor(time_active / player.attack_charge_time)
	if charges > 0:
		charge_count_increase.emit(charges)
	

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.move(delta, 0.25)
	
	time_active += delta
	if charges < player.max_special_charges and floor(time_active / player.special_charge_time) > charges:
		charges += 1
		charge_count_increase.emit()
		if charges == player.max_special_charges:
			max_charge_count.emit()

	if Input.is_action_just_pressed("synergy_burst"):
		trigger_finished.emit(BURSTING)
	if Input.is_action_just_pressed("dodge"):
		player.dash()
		trigger_finished.emit(MOVING if player.velocity else IDLE)
	elif  Input.is_action_just_released("special_attack"):
		if time_active > player.special_charge_time:
			trigger_finished.emit(ATTACKING_CHARGED_SPECIAL, {"charges": charges, "charge_time": time_active})
		else:
			trigger_finished.emit(ATTACKING_SPECIAL)
		
func end() -> void:
	pass
	
func exit() -> void:
	pass
