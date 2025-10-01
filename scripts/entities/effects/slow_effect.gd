class_name SlowStatusEffect extends TimedEntityEffect

var slow_factor: float
var duration: float #in seconds
var elapsed: float = 0.0
var active: bool = false

func _init(_duration: float = 3.0, _slow_factor: float = 0.5)->void:
	id = EffectID.SLOWED
	duration = _duration
	slow_factor = _slow_factor

func try_apply(entity: Entity) -> bool:
	if super(entity):
		elapsed = 0.0
		if not active:
			active = true
			_entity._movement_speed *= slow_factor
		_entity.killed.connect(func()->void: active = false)
		return true
	return false

func process(delta: float) -> bool:
	if not active:
		return false
	elapsed += delta
	if elapsed >= duration:
		return false
	return true

func tick() -> void:
	#Add visual indicator
	pass
	

func stop() -> void:
	if _entity and active:
		_entity._movement_speed *= (1/slow_factor)
	active = false
	return
