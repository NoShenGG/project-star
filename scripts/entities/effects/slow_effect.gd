class_name SlowStatusEffect
extends TimedEntityEffect

var stacks: int
var original_speed: float = 0.0

func _init(_duration: float = 3.0, _stacks := 3) -> void:
	id = EffectID.SLOWED
	stacks = _stacks

	# convert duration to milliseconds since TimedEntityEffect uses ms
	effect_duration = int(_duration * 1000)
	effect_tick_interval = effect_duration  # no ticking, just one duration

func try_apply(entity: Entity) -> bool:
	# Let the base class handle setup and adding as a child
	if not super.try_apply(entity):
		return false

	
	entity.apply_buff(StatMod.DecayDebuff.new(
		StatMod.Stat.SPD, stacks, get_tree().create_timer(effect_duration/1000.0)))

	return true

func tick() -> void:
	# Could add visual indicator here (e.g., slow particles or effect)
	pass

func stop() -> void:
	pass
