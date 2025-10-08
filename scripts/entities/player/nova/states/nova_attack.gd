extends NovaState

var combo_timer: SceneTreeTimer = null
var combo_counter: int = 0
var box: Area3D


func enter(_previous_state_path: String, _data := {}) -> void:
	if combo_timer != null and combo_timer.time_left > 0:
		combo_timer.timeout.disconnect(reset_combo)
		combo_timer = null
	entered.emit(name, _previous_state_path, {"combo": combo_counter})
	box = nova.slash_box if combo_counter in [0,1] else nova.poke_box if combo_counter in [2,3] else nova.sweep_box # Select hitbox based on combo
	box.monitoring = true
	if player.velocity:
		player.velocity *= 0.25 * player._movement_speed / player.velocity.length()
		
	

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.move_and_slide()
		
func do_damage() -> void:
	for node in box.get_overlapping_bodies():
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(nova.attack_dmg[combo_counter])

func reset_combo() -> void:
	combo_counter = 0
	
func end() -> void:
	finished.emit(MOVING if player.velocity else IDLE)
		
func exit() -> void:
	box.monitoring = false
	combo_counter = (combo_counter + 1) % len(nova.attack_dmg)
	combo_timer = get_tree().create_timer(nova.combo_reset_time)
	combo_timer.timeout.connect(reset_combo)
