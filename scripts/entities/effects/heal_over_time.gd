class_name HOT extends TimedEntityEffect

var heal: float

func _init(dur: float, strength: float, ticks: float) -> void:
	id = EffectID.HEAL_OVER_TIME
	effect_duration = floor(dur * 1000)
	effect_tick_interval = floor(effect_duration / ticks) - 5
	heal = strength
	
func tick() -> void:
	if _entity != null:
		_entity.try_heal(heal)
	
func stop() -> void:
	pass
