class_name Broken extends TimedEntityEffect

var move_speed

func _init(_effect: EntityEffect.EffectID, duration_sec: float) -> void:
	effect_duration = floori(duration_sec * 1000)
	effect_tick_interval = effect_duration + 1
	pass
	
func try_apply(entity: Entity) -> bool:
	if not super(entity):
		return false
	move_speed = entity._movement_speed
	entity._movement_speed = 0.0;
	entity._breakable = false
	return true

func tick() -> void:
	pass
	
func stop() -> void:
	_entity._movement_speed = move_speed
	_entity._break_percent = 0.0
	_entity.break_update.emit(0.0)
	get_tree().create_timer(_entity._break_cooldown).timeout.connect(
		func(): 
			_entity._breakable = true)
	pass
