class_name Forte extends TimedEntityEffect

var speed: float
var dmg: float

func _init(duration: float, _speed := 1.25, _damage := 1.5) -> void:
	effect_duration = floor(duration * 1000)
	effect_tick_interval = effect_duration + 1
	speed = _speed
	dmg = _damage
	id = EffectID.FORTE;

# Called when the node enters the scene tree for the first time.
func try_apply(entity: Entity) -> bool:
	if super(entity):
		entity._movement_speed *= speed
		entity.damage_mult *= dmg
		return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(_delta: float) -> bool:
	return super(_delta)
	
func tick() -> void:
	pass

func stop() -> void:
	_entity._movement_speed /= speed
	_entity.damage_mult /= dmg
