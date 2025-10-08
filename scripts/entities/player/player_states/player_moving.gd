extends PlayerState
	

func enter(_prev_state: String, _data := {}):
	entered.emit(name, _prev_state)

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.move(delta)
	if Input.is_action_just_pressed("dodge"):
		player.dash()

	if Input.is_action_just_pressed("synergy_burst"):
		finished.emit(BURSTING)
	elif Input.is_action_just_pressed("special_attack") and player.has_special:
		finished.emit(CHARGING_SPECIAL)
	elif Input.is_action_just_pressed("basic_attack"):
		finished.emit(CHARGING)
	elif not Input.get_vector("move_down", "move_up", "move_left", "move_right"):
		finished.emit(IDLE)
			
func end() -> void:
	pass
		
func exit() -> void:
	pass
