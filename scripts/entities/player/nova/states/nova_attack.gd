extends NovaState

signal update_combo(count: int)

var combo_timer: SceneTreeTimer = null
var combo_counter: int = 0
var box: Area3D

## when we enter into the first attack, a slice
signal on_slice_0
## when we enter into the second attack, a slice
signal on_slice_1
## when we enter into the third attack, a poke
signal on_forward_slam_2
## when we enter into the fourth attack, a sweek
signal on_poke_3
## when we enter into the fifth attack, a sweek
signal on_big_sweep_4

func enter(_previous_state_path: String, _data := {}) -> void:
	if combo_timer != null and combo_timer.time_left > 0:
		combo_timer.timeout.disconnect(reset_combo)
		combo_timer = null
	entered.emit()
	box = nova.slash_box if combo_counter in [0,1] else nova.poke_box if combo_counter in [2,3] else nova.sweep_box # Select hitbox based on combo
	match(combo_counter):
		0:
			on_slice_0.emit.call_deferred()
		1:
			on_slice_1.emit.call_deferred()
		2:
			on_forward_slam_2.emit.call_deferred()
		3:
			on_poke_3.emit.call_deferred()
		4:
			on_big_sweep_4.emit.call_deferred()
	box.monitoring = true
	if player.velocity:
		player.velocity *= (0.25 * player._movement_speed) / player.velocity.length()
		
	

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	player.move_and_slide()
		
func do_damage() -> void:
	for node in box.get_overlapping_bodies():
		print(node)
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(nova.attack_dmg[combo_counter])

func reset_combo() -> void:
	combo_counter = 0
	update_combo.emit(0)
	
func end() -> void:
	trigger_finished.emit(MOVING if player.velocity else IDLE)
		
func exit() -> void:
	box.monitoring = false
	print(combo_counter)
	combo_counter = (combo_counter + 1) % len(nova.attack_dmg)
	update_combo.emit(combo_counter)
	combo_timer = get_tree().create_timer(nova.combo_reset_time)
	combo_timer.timeout.connect(reset_combo)
