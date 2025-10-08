extends NovaState


signal special_dash(chain: bool)

var charges: int = 0
var lock_rotation := true


func enter(_previous_state_path: String, data := {}) -> void:
	entered.emit(name, _previous_state_path)
	charges = data.get("charges", 1)
	nova.dash_box.monitoring = true
	lock_rotation = true
	run_special_dash(true)

	
func run_special_dash(first: bool):
	if charges == 0:
		# Fake Animation Wait to end attack state
		get_tree().create_timer(0.1).timeout.connect(
			finished.emit.bind(MOVING if player.velocity else IDLE))
		return
	elif not first:
		lock_rotation = false
		await get_tree().create_timer(nova.release_pause).timeout
		lock_rotation = true
	special_dash.emit(charges > 1)
	nova.can_dash = true
	player.dash(nova.special_dash_dist)
	do_damage()
	charges -= 1
	run_special_dash(false)
	

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction := Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = direction.rotated(deg_to_rad(45))
	
	player.target_velocity.x = direction.x
	player.target_velocity.z = direction.y
	
	player.look_at(player.global_position + 
			player.target_velocity.lerp(
				Vector3.FORWARD.rotated(Vector3.UP, player.rotation.y),
				clamp(pow(0.1, 2 * player.input_smoothing_speed * delta), 0, 1)))

		
func do_damage() -> void:
	await get_tree().physics_frame
	for node in nova.dash_box.get_overlapping_bodies():
		if not node is Enemy:
			continue
		(node as Enemy).try_damage(nova.special_dmg)
		
func end() -> void:
	pass
		
func exit() -> void:
	nova.dash_box.monitoring = false
	get_tree().create_timer(player.special_cd).timeout.connect(func(): player.has_special = true)
