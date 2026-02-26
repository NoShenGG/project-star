@tool
@icon("uid://biyv27by8gy3r")
class_name PlayerManager
extends Node3D

@onready var current_char: Player
var players: Array[Player]

signal new_player(value : Player)
signal player_hp_update(player: Player, percent: float)
signal player_sp_update(player: Player, percent: float)

signal player_special_ready

# FIXME: hardcoded player names
const NOVA = "Nova"
const RENE = "Rene"
const DAWN = "Dawn"

## forces a character swap when the character dies, requires all characters to go to 0
@export var saving_grace : bool = true 
@export var saving_grace_delay : float = 0.5
@export_enum("One", "Two", "Three") var stage: int = 0

signal game_over

func _init() -> void:
	if (not Engine.is_editor_hint()):
		GameManager.player_manager = self

func _ready() -> void:
	if (Engine.is_editor_hint()): return
	# TODO: Should load or somehow maintain the character's selected char throughout scenes
	# e.g. if the player leaves scene1 and enters scene2, they should have the same selected character
	current_char = get_child(0)
	for c in get_children():
		if !(c is Player): 
			## yes, i know this is a return, i know what it does. no continue
			return
			
		# NOTE: we cannot use one handler for all player health and special emitters: this is 
		# because players that are not the current player can be healed. 
		if c.name in PLAYER_SIGNAL_HANDLERS:
			c.health_update.connect(PLAYER_SIGNAL_HANDLERS[c.name].health)
			c.special_cooldown_update.connect(PLAYER_SIGNAL_HANDLERS[c.name].special)
		
		if c.name != current_char.name:
			c.visible = false
			(c as Player).state_machine.state = c.get_node("StateMachine/Sleeping")
			(c as Player).get_node("CollisionShape3D").disabled = true
		else:
			(c as Player).special_available.connect(await_special)
			(c as Player).killed.connect(on_player_killed.call_deferred)
			
		# use signal directly instead of function because we should pass in the character to update
		player_hp_update.emit(c, c._hp / c._max_hp)
		player_sp_update.emit(c, 1)
		
		c.top_level = true
		c.global_position = global_position
		c.global_rotation = global_rotation
		
		players.append(c)
		if (stage == 0 and players.size() > 1):
			players.resize(1)
		elif (stage == 1 and players.size() > 2):
			players.resize(2)
		elif (stage == 2 and players.size() > 3):
			players.resize(3)


func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()):
		for c in get_children():
			if (c is Player):
				c.global_position = global_position
				c.global_rotation = global_rotation
		return
	
	if current_char.can_swap():
		if (Input.is_action_just_pressed("select_char1")):
			swap_char(0)
		elif (Input.is_action_just_pressed("select_char2") and stage >= 1):
			swap_char(1)
		elif (Input.is_action_just_pressed("select_char3") and stage >= 2):
			swap_char(2)
		
		if (Input.is_action_just_pressed("next_char")):
			print("current character is " + str((players.find(current_char))))
			var new_index : int = (players.find(current_char) + 1) % (players.size())
			print("swapping character to " + str(new_index))
			match new_index:
				0:
					swap_char(0)
				1:
					if (stage >= 1): swap_char(1)
					print("nova")
				2:
					if (stage >= 2): swap_char(2)
		if (Input.is_action_just_pressed("prev_char")):
			print("current character is " + str((players.find(current_char))))
			var new_index : int = players.size() - 1 if (players.find(current_char) - 1) < 0 else players.find(current_char) - 1
			print("swapping character to " + str(new_index))
			match new_index:
				0:
					swap_char(0)
				1:
					if (stage >= 1): swap_char(1)
				2:
					if (stage >= 2): swap_char(2)
	
	## this line works because the players are top_level. 
	## allowing external code to be able to see the player still in edgecases
	global_position = current_char.global_position

class PlayerSignalHandler:
	var health: Callable
	var special: Callable
	
	func _init(health: Callable, special: Callable):
		self.health = health
		self.special = special

var PLAYER_SIGNAL_HANDLERS: Dictionary[String, PlayerSignalHandler] = {
	NOVA: PlayerSignalHandler.new(nova_health_update, nova_special_update),
	DAWN: PlayerSignalHandler.new(dawn_health_update, dawn_special_update),
	RENE: PlayerSignalHandler.new(rene_health_update, rene_special_update),
}

func nova_health_update(percent: float):
	player_hp_update.emit(get_player_by_name(NOVA), percent)
	
func rene_health_update(percent: float):
	player_hp_update.emit(get_player_by_name(RENE), percent)
	
func dawn_health_update(percent: float):
	player_hp_update.emit(get_player_by_name(DAWN), percent)
	
func nova_special_update(percent: float):
	player_sp_update.emit(get_player_by_name(NOVA), percent)
	
func rene_special_update(percent: float):
	player_sp_update.emit(get_player_by_name(RENE), percent)
	
func dawn_special_update(percent: float):
	player_sp_update.emit(get_player_by_name(DAWN), percent)


'''
	Uses node hierarchy for character switching, assuming characters are the only direct children 
	under the player manager. If not, could just group characters under another child node
	e.g. get_node("characters").get_child(idx)
	- PlayerManager
	- - Characters
	- - - Player1
	- - - Player2
		  ...
'''
func swap_char(idx: int):
	if idx < get_child_count() and current_char.name != get_child(idx).name and not get_child(idx).death:
		var new_char := get_child(idx) as Player
		swap_char_to(new_char)

func swap_char_to(new_char: Player):
	new_player.emit(new_char)
	new_char.set_global_transform(current_char.get_global_transform())
	new_char.velocity = current_char.velocity
	new_char.reset_physics_interpolation()
	
	(current_char.state_machine as PlayerStateMachine).swap_out()
	(new_char.state_machine as PlayerStateMachine).swap_in()
	
	current_char.special_available.disconnect(await_special)
	current_char.killed.disconnect(on_player_killed.call_deferred)

	new_char.special_available.connect(await_special)
	new_char.killed.connect(on_player_killed.call_deferred)
	current_char = new_char
	
	# use signal directly instead of function because we should pass in the character to update
	player_hp_update.emit(new_char, new_char._hp / new_char._max_hp)
	player_sp_update.emit(new_char, 1.0 if new_char._has_special else \
		(new_char.special_cd - new_char.special_cd_timer.time_left)/new_char.special_cd)

func await_special():
	print("special ready bounce")
	player_special_ready.emit()
	
func on_player_killed():
	if (!saving_grace):
		game_over.emit()
		return
	
	for c in get_children():
		if not (c is Player):
			break
			
		var p : Player = c as Player
		if (p.name == RENE and stage < 1) or (p.name == DAWN and stage < 2):
			continue
		if p.name != current_char.name and not p.is_dead():
			# found a living player to switch
			if (saving_grace_delay != 0): await get_tree().create_timer(saving_grace_delay).timeout
			swap_char_to(p)
			return
	# didn't find a living player, so game over
	game_over.emit()
	
func get_players() -> Array[Player]:
	return players
	
func get_player_by_name(name: String) -> Player:
	for p in get_players():
		if p.name == name:
			return p
	return null

func team_hurt(damage: float):
	for x in get_players():
		if x is Player:
			# hurts all players
			x.try_damage(damage)

func team_effect(e: Array[EntityEffect]):
	for x in get_players():
		if x is Player and !x.is_dead():
			x.apply_effect(e.pop_front())

func team_heal(amount: float):
	for x in get_players():
		if x is Player and !x.is_dead():
			x.try_heal(amount)

func team_heal_percent(percent: float):
	for x in get_players():
		if x is Player and x._hp != x._max_hp and !x.is_dead():
			x.try_heal((x._max_hp - x._hp) * percent)
