@abstract
class_name Entity extends CharacterBody3D

enum Faction {PLAYER, NEUTRAL, HOSTILE}

signal killed
signal hurt(damage : float)
signal health_update(percent: float)
signal broken
signal break_update(percent: float)

@export var _base_speed: float = 5.0
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
@export var _break_hits: int = 3
@export var _break_drain_rate: float = 0.05
@export var _break_cooldown: float = 5.0
@export var passive_death_time : float = 2.5

@onready var state_machine: StateMachine = $StateMachine

var _status_effects: Dictionary[EntityEffect.EffectID, EntityEffect] = {}
var _stopped_effects: Array[EntityEffect.EffectID] = []
var _buffs: Dictionary[StatMod.Stat, Array] = {}
var damage_mult:
	get():
		return _buffs[StatMod.Stat.DMG].reduce(
			func(acc: float, stat: StatMod): return acc * pow(1.1, stat.poll()), 1.0)
var speed:
	get():
		return _base_speed * _buffs[StatMod.Stat.SPD].reduce(
			func(acc: float, stat: StatMod): return acc * pow(1.2, stat.poll()), 1.0)
var invincible: bool = false

@onready var death: bool = false


func _ready() -> void:
	health_update.emit(1)
	for stat in StatMod.Stat.values():
		_buffs[stat] = []

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
	# Clear Finished Buffs/Debuffs
	for stat in _buffs.values():
		for buff in stat:
			if buff.finished():
				(stat as Array).erase.call_deferred(buff)

func apply_effect(effect: EntityEffect) -> bool:
	_status_effects.set(effect.id, effect)
	return effect.try_apply(self)
	
func apply_buff(buff: StatMod):
	_buffs[buff.type].append(buff)

func try_damage(damage_amount: float) -> bool:
	if (death):
		return false
	
	if damage_amount <= 0:
		assert(false, "Damage amount cannot be <= 0")
		return false
	if invincible:
		print("Damage blocked by invincibility!")
		return false
		
	# Apply Def Buff
	for mod in _buffs[StatMod.Stat.DEF]:
		damage_amount *= pow(0.9, mod.poll())
	
	var new_hp: float = _hp - damage_amount
	_hp = max(new_hp, 0.0)
	if _hp == 0.0:
		trigger_death()
		return true
	hurt.emit(damage_amount)
	if _breakable:
		_break_percent = clamp(_break_percent + 1.0 / _break_hits, 0.0, 1.0)
		if _break_percent == 1.0:
			apply_effect(Broken.new(EntityEffect.EffectID.BROKEN, _break_cooldown))
			broken.emit()
	return true

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
