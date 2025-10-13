class_name GrabbedEffect
extends TimedEntityEffect

@export var tick_ms: int = 100

@export var pull_anchor: Vector3 = Vector3.ZERO
@export var pull_strength: float = 12.0
@export var max_pull_distance: float = 20.0
@export var freeze_velocity_during_pull: bool = true
@export var stun_trigger_distance: float = 1.0

@export var stun_duration_ms: int = 2000
@export var freeze_velocity_during_stun: bool = true

enum Phase { PULLING, STUNNING }
var _phase: Phase = Phase.PULLING

var _original_speed: float = -1.0
var _was_phys := false
var _was_inp  := false
var _was_unh  := false

func _init() -> void:
	id = EffectID.GRABBED
	effect_tick_interval = tick_ms
	effect_duration = 3600000

func try_apply(entity: Entity) -> bool:
	if not super(entity):
		return false
	_phase = Phase.PULLING
	_original_speed = entity._movement_speed
	entity._movement_speed = 0.0
	return true

func process(delta: float) -> bool:
	if not _entity:
		return super(delta)

	if _phase == Phase.PULLING:
		var to_anchor := pull_anchor - _entity.global_position
		var dist := to_anchor.length()
		
		if dist >= max_pull_distance:
			stop()
			queue_free()
			return false
			
		if dist > stun_trigger_distance and dist < max_pull_distance:
			_entity.global_position += to_anchor.normalized() * pull_strength * delta
			if freeze_velocity_during_pull and "velocity" in _entity:
				_entity.velocity = Vector3.ZERO

		if dist <= stun_trigger_distance:
			_enter_stun_phase()
			_current_time = 0
			_last_tick = 0
			effect_duration = stun_duration_ms

	elif _phase == Phase.STUNNING:
		if freeze_velocity_during_stun and "velocity" in _entity:
			_entity.velocity = Vector3.ZERO

	return super(delta)

func _enter_stun_phase() -> void:
	_phase = Phase.STUNNING
	_entity.set_meta("stunned", true)
	_was_phys = _entity.is_physics_processing()
	_was_inp  = _entity.is_processing_input()
	_was_unh  = _entity.is_processing_unhandled_input()
	_entity.set_physics_process(false)
	_entity.set_process_input(false)
	_entity.set_process_unhandled_input(false)
	if freeze_velocity_during_stun and "velocity" in _entity:
		_entity.velocity = Vector3.ZERO

func tick() -> void:
	pass

func stop() -> void:
	if _entity and _original_speed >= 0.0:
		_entity._movement_speed = _original_speed
	if _entity:
		if _phase == Phase.STUNNING:
			_entity.set_meta("stunned", false)
			_entity.set_physics_process(_was_phys)
			_entity.set_process_input(_was_inp)
			_entity.set_process_unhandled_input(_was_unh)
	queue_free()
