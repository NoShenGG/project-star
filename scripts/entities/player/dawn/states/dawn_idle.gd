extends PlayerState

var time_active: float = 0
var charge_attack: bool = false
var charge_special: bool = false

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	player.velocity = Vector3.ZERO
	time_active = 0
	charge_attack = false
	charge_special = false

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.move_and_slide()
	
	if charge_attack or charge_special:
		time_active += delta
		if time_active > player.max_click_time:
			if charge_special:
				trigger_finished.emit(CHARGING_SPECIAL, {"time": time_active})
			else:
				trigger_finished.emit(CHARGING, {"time": time_active})

	if Input.is_action_just_pressed("synergy_burst"):
		trigger_finished.emit(BURSTING)
	elif Input.get_vector("move_down", "move_up", "move_left", "move_right"):
		trigger_finished.emit(MOVING)
	elif Input.is_action_just_pressed("special_attack"):
		if (charge_attack):
			trigger_finished.emit(ALT_ATTACK)
		charge_special = true
	elif Input.is_action_just_released("special_attack"):
		charge_special = false
		trigger_finished.emit(SPECIAL, {"charges": 1})
	elif Input.is_action_pressed("basic_attack"):
		if (charge_special):
			trigger_finished.emit(ALT_ATTACK)
		charge_attack = true
	elif Input.is_action_just_released("basic_attack"):
		charge_attack = false
		trigger_finished.emit(ATTACKING)
	
		
func end() -> void:
	pass
		
func exit() -> void:
	pass
