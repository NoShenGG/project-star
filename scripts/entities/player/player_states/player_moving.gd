extends PlayerState

var time_active: float = 0
var attack_type: int = 0
	

func enter(_prev_state: String, _data := {}):
	entered.emit()
	time_active = 0
	attack_type = 0

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.move(delta)
	if Input.is_action_just_pressed("dodge"):
		player.dash()
		
	if attack_type != 0:
		time_active += delta
		if time_active > player.max_click_time:
			if attack_type == 1:
				player.has_special = false
				trigger_finished.emit(CHARGING_SPECIAL, {"time": time_active})
			else:
				trigger_finished.emit(CHARGING, {"time": time_active})

	if Input.is_action_just_pressed("synergy_burst"):
		trigger_finished.emit(BURSTING)
	elif not Input.get_vector("move_down", "move_up", "move_left", "move_right"):
		trigger_finished.emit(IDLE)
	elif Input.is_action_just_pressed("special_attack") and attack_type != 2 and player.has_special:
		attack_type = 1
	elif Input.is_action_just_released("special_attack") and attack_type == 1:
		attack_type = 0
		player.has_special = false
		trigger_finished.emit(ATTACKING_SPECIAL)
	elif Input.is_action_pressed("basic_attack") and attack_type != 1:
		attack_type = 2
	elif Input.is_action_just_released("basic_attack") and attack_type == 2:
		attack_type = 0
		trigger_finished.emit(ATTACKING)
			
func end() -> void:
	pass
		
func exit() -> void:
	pass
