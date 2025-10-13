@abstract
class_name Entity extends CharacterBody3D

enum Faction {PLAYER, NEUTRAL, HOSTILE}

signal killed
signal hurt(damage : float)
signal health_update(percent: float)
signal broken
signal break_update(percent: float)

@export var _movement_speed: float = 1.0
@export var faction: Faction = Faction.NEUTRAL
@export var _hp: float = 10.0:
	set(value):
		_hp = value
		health_update.emit(value / _max_hp)
@export var _max_hp: float = 10.0
@export var _breakable: bool = true
@export var _break_percent: float = 0.0:
	set(value):
		_break_percent = value
		break_update.emit(value)
@export var _break_gain_rate: float = 2.0
@export var _break_drain_rate: float = 0.05
@export var _break_cooldown: float = 5.0
@export var passive_death_time : float = 2.5

@onready var state_machine: StateMachine = $StateMachine

var _status_effects: Dictionary[EntityEffect.EffectID, EntityEffect] = {}
var _stopped_effects: Array[EntityEffect.EffectID] = []

func _ready() -> void:
	health_update.emit(1)

func _process(delta: float) -> void:
	if (death): return
	
	for id: EntityEffect.EffectID in _status_effects:
		var effect = _status_effects.get(id)
		if not effect.process(delta):
			effect.stop()
			_stopped_effects.append(id)
	for id: EntityEffect.EffectID in _stopped_effects:
		_status_effects.erase(id)
	_stopped_effects.clear()
	if _breakable:
		_break_percent = clamp(_break_percent - delta * _break_drain_rate, 0.0, 1.0)

func apply_effect(effect: EntityEffect):
	_status_effects.set(effect.id, effect)
	effect.try_apply(self)

func try_damage(damage_amount: float) -> bool:
	if (death):
		return false
	
	if damage_amount <= 0:
		assert(false, "Damage amount cannot be <= 0")
		return false
	if _status_effects.has(EntityEffect.EffectID.INVINCIBLE):
		# play invincibility animation perhaps?
		print("Damage blocked by invincibility!")
		return true
	var new_hp: float = _hp - damage_amount
	_hp = max(new_hp, 0.0)
	if _hp == 0.0:
		trigger_death()
		return true
	hurt.emit(damage_amount)
	if _breakable:
		_break_percent = clamp(_break_percent + _break_gain_rate * (damage_amount / _max_hp), 0.0, 1.0)
		if _break_percent == 1.0:
			apply_effect(Broken.new(EntityEffect.EffectID.BROKEN, _break_cooldown))
			broken.emit()
	return true

var death: bool =false

func try_heal(heal_amount: float) -> bool:
	if heal_amount <= 0:
		assert(false, "Heal amount cannot be <= 0")
		return false
	var new_hp: float = _hp + heal_amount
	if new_hp > _max_hp:
		_hp = _max_hp
	else:
		_hp = new_hp
	return true


func trigger_death():
	killed.emit()
	death = true
	collision_layer = 0
	await get_tree().create_timer(passive_death_time).timeout
	self.call_deferred("queue_free")
