extends NovaComboState

func enter(_prev_state: String, _data := {}) -> void:
	super(_prev_state, _data)
	nova.poke_box.monitoring = true
	if player.velocity:
		player.velocity *= (0.25 * player._movement_speed) / player.velocity.length()

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.move_and_slide()
	
func do_damage() -> void:
	for node in nova.poke_box.get_overlapping_bodies():
		if node is Enemy:
			(node as Enemy).try_damage(player.attack_dmg[combo_num])	
	
func exit() -> void:
	nova.poke_box.monitoring = false
