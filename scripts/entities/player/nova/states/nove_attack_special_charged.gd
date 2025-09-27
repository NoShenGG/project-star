extends NovaState

var old_direction := Vector3.ZERO
var target_direction := Vector3.ZERO
var look_smoothing_counter: float = 0
var charges: int = 0
var lock_rotation := true


func enter(_previous_state_path: String, data := {}) -> void:
	nova.dash_box.monitoring = true
	old_direction = Vector3.FORWARD.rotated(Vector3.UP, player.rotation.y)
	lock_rotation = true
	charges = mini(data.get("charge_time", 1)/nova.special_charge_time, nova.max_charges)
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
	nova.special_dash.emit(charges > 1)
	nova.can_dash = true
	player.dash(nova.special_dash_dist)
	do_damage()
	charges -= 1
	run_special_dash(false)
	

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	var direction = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	
	direction = Vector3(direction.x, 0, direction.y)
	direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, deg_to_rad(-45))
	
	if direction != target_direction:
		look_smoothing_counter = 0
		old_direction = Vector3.FORWARD.rotated(Vector3.UP, player.rotation.y)
	if look_smoothing_counter < 1:
		look_smoothing_counter += delta / player.input_smoothing_time
	target_direction = direction
		
	player.look_at(player.global_position + old_direction.lerp(target_direction, clamp(look_smoothing_counter, 0, 1)))

		
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
