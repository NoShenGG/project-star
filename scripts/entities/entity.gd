@abstract
class_name Entity extends CharacterBody3D

enum Faction {PLAYER, NEUTRAL, HOSTILE}

signal killed
signal hurt(damage : float)
signal health_update(percent: float)

@export var _movement_speed: float = 1.0
@export var faction: Faction = Faction.NEUTRAL
@export var _hp: float = 10.0
@export var _max_hp: float = 10.0

@onready var state_machine: StateMachine = $StateMachine

var _status_effects: Dictionary[EntityEffect.EffectID, EntityEffect] = {}
var _stopped_effects: Array[EntityEffect.EffectID] = []

func _ready() -> void:
	health_update.emit(1)

func _process(delta: float) -> void:
	for id: EntityEffect.EffectID in _status_effects:
		var effect = _status_effects.get(id)
		if not effect.process(delta):
			effect.stop()
			_stopped_effects.append(id)
	for id: EntityEffect.EffectID in _stopped_effects:
		_status_effects.erase(id)
	_stopped_effects.clear()

func apply_effect(effect: EntityEffect):
	_status_effects.set(effect.id, effect)
	effect.try_apply(self)

func try_damage(damage_amount: float) -> bool:
	if damage_amount <= 0:
		assert(false, "Damage amount cannot be <= 0")
		return false
	if _status_effects.has(EntityEffect.EffectID.INVINCIBLE):
		# play invincibility animation perhaps?
		print("Damage blocked by invincibility!")
		return true
	var new_hp: float = _hp - damage_amount
	if new_hp > 0.0:
		_hp = new_hp
		hurt.emit(damage_amount)
	else:
		_hp = 0.0
		trigger_death()
	health_update.emit(_hp / _max_hp)
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
	health_update.emit(_hp / _max_hp)
	return true

func trigger_death():
	killed.emit()
	self.call_deferred("queue_free")
