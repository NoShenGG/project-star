@tool
@icon("uid://biyv27by8gy3r")
class_name PlayerManager
extends Node3D


@export var nova: Nova
@export var rene: Player
@export var dawn: Player

var player_map = {}
var current_char: Player
var current_char_name: Players
var curr_mode: Mode
var burst_done_count := 0

signal bursting_select
signal bursting_start
signal bursting_done
signal new_player(value : Player)
signal player_hp_update(percent: float)
signal player_sp_update(percent: float)
signal player_special_ready

enum Players {
	NOVA,
	RENE,
	DAWN
}

enum Mode {
	NORMAL,
	SELECTING,
	BURSTING
}


func _init() -> void:
	if (not Engine.is_editor_hint()):
		GameManager.player_manager = self

func _ready() -> void:
	if (Engine.is_editor_hint()): return
	
	assert(nova != null and rene != null and dawn != null, "PROVIDE PLAYERS TO MANAGER")
	player_map[Players.NOVA] = nova
	player_map[Players.RENE] = rene
	player_map[Players.DAWN] = dawn
	
	# TODO: Should load or somehow maintain the character's selected char throughout scenes
	# e.g. if the player leaves scene1 and enters scene2, they should have the same selected character
	current_char = nova
	current_char_name = Players.NOVA
	for c in player_map.values():
		c = c as Player
		(c.state_machine as PlayerStateMachine).burst_state.burst_done.connect(
				end_burst)
		if c.name != current_char.name:
			c.visible = false
			c.state_machine.state = c.get_node("StateMachine/Sleeping")
			c.get_node("CollisionShape3D").disabled = true
		else:
			c.health_update.connect(player_health_update)
			c.special_cooldown_update.connect(player_special_update)
			c.special_available.connect(await_special)
			player_health_update(c._hp / c._max_hp)
			player_special_update(1)
		c.top_level = true
		c.global_position = global_position
		c.global_rotation = global_rotation
		
	

func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()):
		for c in get_children():
			if (c is Player):
				c.global_position = global_position
				c.global_rotation = global_rotation
		return
	if curr_mode == Mode.SELECTING:
		if Input.is_action_just_pressed("select_char1") and current_char != nova:
			trigger_burst(Players.NOVA)
		elif Input.is_action_just_pressed("select_char2") and current_char != rene:
			trigger_burst(Players.RENE)
		elif Input.is_action_just_pressed("select_char3") and current_char != dawn:
			trigger_burst(Players.DAWN)
	
	elif curr_mode == Mode.NORMAL:
		if Input.is_action_just_pressed("synergy_burst"):
			curr_mode = Mode.SELECTING
			current_char.process_mode = Node.PROCESS_MODE_DISABLED
			bursting_select.emit()
		
		elif current_char.can_swap():
			if (Input.is_action_just_pressed("select_char1")):
				swap_char(Players.NOVA)
			elif (Input.is_action_just_pressed("select_char2")):
				swap_char(Players.RENE)
			elif (Input.is_action_just_pressed("select_char3")):
				swap_char(Players.DAWN)
	
	## this line works because the players are top_level. 
	## allowing external code to be able to see the player still in edgecases
	global_position = current_char.global_position

func player_health_update(percent: float):
	player_hp_update.emit(percent)
	
func player_special_update(percent: float):
	player_sp_update.emit(percent)


func trigger_burst(other: Players) -> void:
	curr_mode = Mode.BURSTING
	burst_done_count = 0
	bursting_start.emit()
	current_char.process_mode = Node.PROCESS_MODE_ALWAYS
	current_char.state_machine.state.trigger_finished.emit(
				PlayerState.BURSTING, {"player": other})
	var other_char = player_map[other] as Player
	other_char.visible = true
	other_char.state_machine.state.trigger_finished.emit(
				PlayerState.BURSTING, {"player": current_char_name})
	other_char.set_global_transform(current_char.get_global_transform())
	# For Debugging to see both chars
	other_char.position += Vector3.RIGHT.rotated(Vector3.UP, other_char.rotation.y) * 3
				
	await bursting_done
	current_char.state_machine.state.end()
	other_char.state_machine.state.end_sleep()
	other_char.visible = false
	

func end_burst() -> void:
	burst_done_count += 1
	if burst_done_count == 2:
		curr_mode = Mode.NORMAL
		bursting_done.emit()
		


func swap_char(player: Players):
	if player_map[player] == current_char:
		print("same")
		return
	var new_char := player_map[player] as Player
	new_player.emit(new_char)
	new_char.set_global_transform(current_char.get_global_transform())
	new_char.velocity = current_char.velocity
	new_char.reset_physics_interpolation()
	
	(current_char.state_machine as PlayerStateMachine).swap_out()
	(new_char.state_machine as PlayerStateMachine).swap_in()
	
	current_char.special_available.disconnect(await_special)
	current_char.health_update.disconnect(player_health_update)
	current_char.special_cooldown_update.disconnect(player_special_update)
	new_char.health_update.connect(player_health_update)
	new_char.special_cooldown_update.connect(player_special_update)
	new_char.special_available.connect(await_special)
	player_health_update(new_char._hp / new_char._max_hp)
	if new_char.special_cd_timer == null:
		player_special_update(1)
	current_char = new_char
	current_char_name = player

func await_special():
	print("special ready bounce")
	player_special_ready.emit()
