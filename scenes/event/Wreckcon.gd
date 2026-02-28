extends Node

# List of tasks
enum Task {
	NovaDash,
	ReneSmite,
	DawnSustain,
	DawnChilling,
	Combo100,
	Switch100,
	WinGame,
	Speedrun,
	NoDeath
}

# Maps tasks to process functions
var map = {
	Task.NovaDash: process_nova_dash,
	Task.ReneSmite: process_rene_smite,
	Task.DawnSustain: process_dawn_sustain,
	Task.DawnChilling: process_dawn_chilling,
	Task.Combo100: process_combo_100,
	Task.Switch100: process_switch_100,
	Task.WinGame: process_win_game,
	Task.Speedrun: process_speedrun,
	Task.NoDeath: process_no_death
}

# Task Arrays
var complete: PackedInt32Array = []
var todo: PackedInt32Array = []

# Global vars
var curr_level = null
var is_level = false

# UI
var ui: Menu
var menu_open = false
var stars: Array[TextureRect] = []


# Loads todo array with all tasks
func _ready() -> void:
	for task in map.keys():
		todo.append(task)
	ui = preload("res://scenes/event/Wreckcon_UI.tscn").instantiate()
	add_child(ui)
	for child in ui.get_children()[0].get_children()[0].get_children()[0].get_children():
		var star = child.get_children()[0] as TextureRect
		star.hide()
		stars.append(star)

# Calls processors and updates task statuses
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("journal"):
		if menu_open:
			menu_open = false
			ui.close()
		else:
			menu_open = true
			ui.open()
	if (GameManager.current_level == null):
		return
	is_level = (GameManager.current_level.name as String).contains("Level")
	# Reset Handlers for new level
	if (GameManager.current_level != curr_level):
		p_d_s_state = 0b00
		p_d_c_state = 0b00
		switch_init = false
		death_init = false
		curr_level = GameManager.current_level
	# Run processors, clean up completed tasks
	var to_remove: PackedInt32Array = []
	for task in todo:
		if (map.get(task) as Callable).call():
			stars[task].show()
			complete.append(task)
			to_remove.append(task)
	for task in to_remove:
		todo.erase(task)


# Nova Triple Dash Task
func process_nova_dash() -> bool:
	if not is_level: return false
	var nova = GameManager.curr_player as Nova
	if (nova != null):
		var state = nova.state_machine.state
		if (state == null): return false
		if (state.name != "Special"): return false
		return state._state_queue.size() > 3
	return false


# Rene 4 Charge Smite Task
func process_rene_smite() -> bool:
	if not is_level: return false
	var rene = GameManager.curr_player as Rene
	if (rene != null):
		var state = rene.state_machine.state as ReneCharged
		if (state == null): return false
		return rene.counters >= 4
	return false


# Dawn Sustain Note Task
var p_d_s_state = 0b00 # 00=waiting for valid dawn to init, 01=waiting for note fire, 10=checking if note hit
func process_dawn_sustain() -> bool:
	if not is_level: return false
	if p_d_s_state == 0b00:
		var dawn = GameManager.curr_player as Dawn
		if (dawn != null):
			var state = dawn.state_machine.get_node("Special/SpecialAbility")
			if (state == null): return false
			state.wave.fire.connect(func(): p_d_s_state = 0b10, CONNECT_DEFERRED + CONNECT_ONE_SHOT)
			p_d_s_state = 0b01
	if p_d_s_state == 0b01: return false
	if p_d_s_state == 0b10: 
		var dawn = GameManager.curr_player as Dawn
		if (dawn != null):
			var tone = dawn.tone_emitter.get_node("ToneWave")
			if tone == null:
				p_d_s_state = 0b00
				return false
			if tone.hit.size() > 0:
				p_d_s_state = 0b11
				return true
	return false


# Dawn Chilling Note Task
var p_d_c_state = 0b00 # 00=waiting for valid dawn to init, 01=waiting for note fire, 10=checking if note hit
func process_dawn_chilling() -> bool:
	if not is_level: return false
	if p_d_c_state == 0b00:
		var dawn = GameManager.curr_player as Dawn
		if (dawn != null):
			var state = dawn.state_machine.get_node("Special/SpecialAbility")
			if (state == null): return false
			state.ice.fire.connect(func(): p_d_c_state = 0b10, CONNECT_DEFERRED + CONNECT_ONE_SHOT)
			p_d_c_state = 0b01
	if p_d_c_state == 0b01: return false
	if p_d_c_state == 0b10: 
		var dawn = GameManager.curr_player as Dawn
		if (dawn != null):
			var tone = dawn.tone_emitter.get_node("ToneIce")
			if tone == null:
				p_d_c_state = 0b00
				return false
			if tone.in_zone.size() > 0:
				p_d_c_state = 0b11
				return true
	return false


# Hit 100 Combo Task
func process_combo_100() -> bool:
	if not is_level: return false
	return GameManager.player_manager.combo_counter.combo >= 100


# Switch Characters 100 Times Task
var switches: int = 0
var switch_init = false
func switch_callback(_a): switches += 1
func process_switch_100() -> bool:
	if not is_level: return false
	if not switch_init:
		GameManager.player_manager.new_player.connect(switch_callback)
		switches = 0
		switch_init = true
	return switches >= 100


# Win Game Task
func process_win_game() -> bool:
	return GameManager.current_level.name == "Credits"


# Beat Game in Under 10 Mins Task
var timer: SceneTreeTimer
var speedrun_init = false
func process_speedrun() -> bool:
	if not is_level:
		if GameManager.current_level.name == "Credits":
			if timer == null: return false
			return timer.time_left > 0
		return false
	if not speedrun_init:
		timer = get_tree().create_timer(60*10)
		speedrun_init = true
	return false


# Win Game With No Deaths Task
var death = false
var death_init = false
func process_no_death() -> bool:
	if not is_level:
		if GameManager.current_level.name == "Credits":
			return not death
		return false
	if not death_init:
		GameManager.player_manager.player_hp_update.connect(func(_p, hp): if hp <= 0: death = true)
		death_init = true
	return false
