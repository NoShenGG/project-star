@abstract
class_name EntityEffect extends Node3D

enum EffectID {
	DEBUG_EFFECT
}
var id: EffectID
var _entity: Entity

@abstract
func _init(effect_id: EffectID) -> void

## Called whenever the [EntityEffect] is applied or reapplied.[br]
## Returns false if provided [Entity] is null, true if valid
func try_apply(entity: Entity) -> bool:
	if not entity:
		assert(false, "Entity not provided for effect")
		return false
	_entity = entity
	entity.add_child(self)
	return true

## Called to process the [EntityEffect] and indicate when it is done.[br]
## Returns true if still in progress, returns false if effect has finished.
@abstract
func process(delta: float) -> bool

## Called when the [EntityEffect] should be removed.[br]
## Performs any necessary cleanup and applies any permanent effects.[br]
@abstract
func stop() -> void
