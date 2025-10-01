@abstract
class_name Boss extends Enemy

"""
TODO:
	boss phase
	special attack
	movement
"""

enum BossPhase {
	NORMAL,
	FINAL
}

enum BossState {
	CHASING,
	ATTACKING,
	CHARGING,
	SWITCHING
}

@onready var _phase := BossPhase.NORMAL
@onready var _state := BossState.CHASING
@export_range(0,100,1) var _phase_switch_hp_percentage: int = 50

# specify id of attack:
# 0 -> base attack
# x -> special attack with id=x
@export var _attack_pattern_normal: Array[int] = []
@export var _attack_pattern_final: Array[int] = []
# charging time of a special attack
@export var _charging_time: Dictionary[int, float]

@onready var _timer: float = 0.0
@onready var _curr_attack: int = 0
@onready var _switch_hp = _max_hp * _phase_switch_hp_percentage / 100


func try_damage(damage_amount: float) -> bool:
	if damage_amount <= 0:
		assert(false, "Damage amount cannot be <= 0")
		return false
	var new_hp = _hp - damage_amount
	if _phase == BossPhase.NORMAL and new_hp < _switch_hp:
		_hp = _switch_hp
		phase_change()
	elif _phase == BossPhase.FINAL and new_hp <= 0.0:
		_hp = 0.0
		_die()
	else:
		_hp = new_hp
	return true


func try_heal(heal_amount: float) -> bool:
	if heal_amount <= 0:
		assert(false, "Heal amount cannot be <= 0")
		return false
	var new_hp = _hp + heal_amount
	if _phase == BossPhase.NORMAL:
		new_hp = min(new_hp, _max_hp)
	else:
		new_hp = min(new_hp, _switch_hp)
	_hp = new_hp
	return true


# handle attack pattern
func attack() -> void:
	_state = BossState.ATTACKING
	var att_pattern = _attack_pattern_normal
	if _phase == BossPhase.FINAL:
		att_pattern = _attack_pattern_final
	
	if _curr_attack >= len(att_pattern):
		_curr_attack = 0
	
	if att_pattern[_curr_attack] == 0:
		_attack()
	else:
		special_attack(att_pattern[_curr_attack])
	
	_curr_attack = _curr_attack + 1


func special_attack(_attack_id: int) -> void:
	if _charging_time.has(_attack_id):
		_state = BossState.CHARGING
		_timer = _charging_time[_attack_id]
	else:
		_special_attack(_attack_id)


func phase_change() -> void:
	_phase = BossPhase.FINAL
	_state = BossState.SWITCHING
	_curr_attack = 0


func _physics_process(_delta: float) -> void:
	if _state == BossState.CHARGING:
		_timer = _timer - _delta
		if _timer <= 0.0:
			_timer = 0.0
			_state = BossState.ATTACKING
			_special_attack(_curr_attack)
	
	if _state == BossState.CHASING:
		super._physics_process(_delta)


# define special attacks
@abstract func _special_attack(_attack_id: int) -> void

# define normal attack
@abstract func _attack() -> void

# define death effects
@abstract func _die() -> void

# define phase change effects
@abstract func _phase_change() -> void
