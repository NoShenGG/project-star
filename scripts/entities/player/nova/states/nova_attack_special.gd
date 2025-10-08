extends NovaState

signal special_dash(chain: bool)

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit(name, _previous_state_path)
	nova.dash_box.monitoring = true
	nova.can_dash = true
	get_tree().physics_frame.connect(do_damage)
	player.dash(nova.special_dash_dist)
	

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.move_and_slide()
		
func do_damage() -> void:
	for node in nova.dash_box.get_overlapping_bodies():
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(nova.special_dmg)
	get_tree().physics_frame.disconnect(do_damage)
	special_dash.emit(false)
	end()
	
		
func end() -> void:
	finished.emit(MOVING if player.velocity else IDLE)
		
func exit() -> void:
	nova.dash_box.monitoring = false
	get_tree().create_timer(player.special_cd).timeout.connect(func(): player.has_special = true)
