extends NovaState

signal special_dash(chain: bool)

@export var hitbox : Area3D

func enter(_previous_state_path: String, _data := {}) -> void:
	entered.emit()
	hitbox.monitoring = true
	nova.can_dash = true
	get_tree().physics_frame.connect(do_damage)
	player.dash(nova.special_dash_dist, false)
	

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.move_and_slide()
		
func do_damage() -> void:
	for node in hitbox.get_overlapping_bodies():
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(nova.special_dmg)
	get_tree().physics_frame.disconnect(do_damage)
	special_dash.emit(false)
	end()
	
		
func end() -> void:
	trigger_finished.emit(MOVING if player.velocity else IDLE)
		
func exit() -> void:
	hitbox.monitoring = false
	get_tree().create_timer(player.special_cd).timeout.connect(func(): player.has_special = true)
