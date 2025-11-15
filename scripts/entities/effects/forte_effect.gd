class_name Forte extends TimedEntityEffect

var spd: int
var dmg: int

func _init(duration: float, _speed := 2, _damage := 2) -> void:
	effect_duration = floor(duration * 1000)
	effect_tick_interval = effect_duration + 1
	spd = _speed
	dmg = _damage
	id = EffectID.FORTE;

# Called when the node enters the scene tree for the first time.
func try_apply(entity: Entity) -> bool:
	if super(entity):
		entity.apply_buff(StatMod.Buff.new(
			StatMod.Stat.SPD, spd, get_tree().create_timer(effect_duration/1000.0)))
		entity.apply_buff(StatMod.Buff.new(
			StatMod.Stat.DMG, dmg, get_tree().create_timer(effect_duration/1000.0)))
		return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(_delta: float) -> bool:
	return super(_delta)
	
func tick() -> void:
	pass

func stop() -> void:
	pass
